# ASMBF

## Important: AMD64 programs can also run on Intel machines! Don't be fooled by the name.

ASMBF is a brainfuck interpreter written in pure AMD64 assembly, solely utilizing Linux syscalls. libc isn't used! Due to being written in pure AMD64 assembly (not utilizing ``int 80h``), this program can be run in the Windows Subsystem for Linux.

Right now, ASMBF only reads the brainfuck code from the console itself. Reading from a file will be added soon.

## Compiling

```
$ nasm -f elf64 bf.asm
$ ld -m elf_x86_64 -o bf bf.o
```

Alternatively, a small script is provided. (Not a makefile, because this never was supposed to be a multifile project.)

```
$ ./build.sh
```

## Usage

Simply run the program and enter the brainfuck code.

```
$ ./bf
Enter your brainfuck code:
```

For example:
```
$ ./bf
Enter your brainfuck code:
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.
Hello World!
```
