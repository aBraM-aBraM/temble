.globl main

.section .bss
buffer: .space 4096

.section .data
filename: .asciz    "example.txt"
log_syntax: .asciz  "syntax: ./temble <source-file>\n"

.section .text
.extern open
.extern read
.extern fstat
.extern exit
.extern printf
.extern perror

fatal_errno:
# prints errno using strerror
# and exits using %eax as exit code

    push $0
    call perror 

    push $1
    jmp finish

read_source_file:
    # open file to compile
    # expects filename in %eax

    push $0 # readonly
    push %eax
    call open

    addl $8, %esp 

    # check fd
    cmp $0, %eax
    je fatal_errno

    push $4096 # count 
    lea buffer, %ebx
    push %ebx  # buf
    push %eax  # fd
    call read

    addl $12, %esp

    cmp $-1, %eax
    je fatal_errno

    ret

argparse:
    # checks that a filename argument was given
    # returns filename in %eax
    mov 0x8(%ebp), %eax

    cmp $2, %eax
    jge argparse_contains_filename

    lea log_syntax, %eax
    push %eax
    call printf

    addl $4, %esp

    push $1
    jmp finish

argparse_contains_filename:

    # retrieve argv[1]
    mov 0xc(%ebp), %ebx
    mov 0x4(%ebx), %eax

    ret

main:
    push %ebp
    mov %esp, %ebp

    call argparse

    call read_source_file

    push $0
finish:
    call exit
