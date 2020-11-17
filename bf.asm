section .data
    msg db 'Enter your brainfuck code:', 0Ah
    newline db 0Ah

    STDOUT equ 1
    STDIN equ 0

    SYS_READ equ 0
    SYS_WRITE equ 1
    SYS_EXIT equ 60

section .bss
    programBuf resb 10000
    programBuf_ptr resq 1
    inputBuf resb 1
    mem resb 10000
    mem_ptr resq 1
    outputBuf resb 1
    loopBegin resq 100
    loopDepth resq 1

section .text

memset: ; al: val, rsi: buf, rdi: n
    push rcx
    xor rcx, rcx

    .loop:
        mov byte [rsi + rcx], al
        inc rcx
        cmp rcx, rdi
    jne .loop

    pop rcx
    ret
; end memset

ptr_inc:
    inc qword [mem_ptr]

    ret
; end mem_ptr_inc

ptr_dec:
    dec qword [mem_ptr]

    ret
; end mem_ptr_dec

cell_inc:
    mov rbx, qword [mem_ptr]
    mov al, byte [rbx]
    inc al
    mov byte [rbx], al
    ret
; end cell_inc 

cell_dec:
    mov rbx, qword [mem_ptr]
    mov al, byte [rbx]
    dec al
    mov byte [rbx], al
    ret
; end cell_dec 

cell_print:
    mov rbx, qword [mem_ptr]
    mov al, byte [rbx]
    mov byte [outputBuf], al

    mov rdx, 1
    mov rsi, outputBuf
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall

    ret
; end cell_print

cell_input:
    mov rdx, 1
    mov rsi, inputBuf
    mov rdi, STDIN
    mov rax, SYS_READ
    syscall

    mov al, byte [inputBuf]
    mov rbx, qword [mem_ptr]
    mov byte [ebx], al

    ret
; end cell_input

loop_begin:
    mov rcx, qword [loopDepth]
    mov rbx, qword [programBuf_ptr]
    mov qword [loopBegin + 8 * rcx], rbx
    inc qword [loopDepth]

    ret
; end loop_begin

loop_end:
    mov rbx, qword [mem_ptr]
    mov al, byte [ebx]

    cmp al, 0
    jnz .not_zero
        dec qword [loopDepth]
        jmp .loop_end_done
    .not_zero:
        mov rcx, qword [loopDepth]
        dec rcx
        mov rbx, qword [loopBegin + 8 * rcx]
        mov qword [programBuf_ptr], rbx
    .loop_end_done:
    ret
; end loop_end

global _start
_start:
    mov rdx, 27
    mov rsi, msg
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall

    mov rdi, 10000
    mov rsi, mem
    mov al, 0
    call memset

    mov qword [mem_ptr], mem
    mov qword [programBuf_ptr], programBuf
    mov qword [loopDepth], 0

    .read_loop:
        mov rdx, 1
        mov rsi, inputBuf
        mov rdi, STDIN
        mov rax, SYS_READ
        syscall

        mov rbx, qword [programBuf_ptr]
        mov cl, byte [inputBuf]
        mov byte [rbx], cl

        cmp rax, 0
        je .read_done

        cmp byte [inputBuf], 0Ah ; Debug thing (newlines checked for console only, files should allow them!)
        je .read_done

        inc qword [programBuf_ptr]

        jmp .read_loop
    .read_done:

    mov byte [rbx], 0

    mov qword [programBuf_ptr], programBuf

    .main_loop:
        mov rbx, qword [programBuf_ptr]
        mov dl, byte [rbx]
        mov byte [inputBuf], dl

        cmp byte [inputBuf], 0
        je .done

        cmp byte [inputBuf], '>'
        jne .not_inc
            call ptr_inc
            jmp .input_parsing_done

        .not_inc: cmp byte [inputBuf], '<'
        jne .not_dec
            call ptr_dec
            jmp .input_parsing_done

        .not_dec: cmp byte [inputBuf], '+'
        jne .not_cell_inc
            call cell_inc
            jmp .input_parsing_done
        
        .not_cell_inc: cmp byte [inputBuf], '-'
        jne .not_cell_dec
            call cell_dec
            jmp .input_parsing_done
        
        .not_cell_dec: cmp byte [inputBuf], '.'
        jne .not_cell_print
            call cell_print
            jmp .input_parsing_done
        
        .not_cell_print: cmp byte [inputBuf], ','
        jne .not_cell_input
            call cell_input
            jmp .input_parsing_done
        
        .not_cell_input: cmp byte [inputBuf], '['
        jne .not_loop_begin
            call loop_begin
            jmp .input_parsing_done
        
        .not_loop_begin: cmp byte [inputBuf], ']'
        jne .not_loop_end
            call loop_end
            jmp .input_parsing_done
        
        .not_loop_end:

        .input_parsing_done:

        inc qword [programBuf_ptr]

        jmp .main_loop

    .done: 

    mov rdx, 1
    mov rsi, newline
    mov rdi, STDOUT
    mov rax, SYS_WRITE
    syscall

    xor rdi, rdi
    mov rax, SYS_EXIT
    syscall