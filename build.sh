if nasm -f elf64 bf.asm ; then
    if ld -m elf_x86_64 -o bf bf.o ; then
        rm bf.o
    fi
fi