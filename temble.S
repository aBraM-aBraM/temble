.globl main

.section .bss
buffer: .space 4096

.section .data
g_verbose: .int 0

CSTRUC_STAT_SIZE: .int 88
CSTRUCT_STAT_ST_SIZE_OFFSET: .int 44

argparse_verbose: .asciz "-v"
log_verbose: .asciz "running verbose\n"
log_syntax: .asciz  "syntax: ./temble <source-file> [-v]\n"

.section .text
.extern open
.extern read
.extern fstat
.extern exit
.extern printf
.extern perror
.extern strcmp


fatal_errno:
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

    mov 0x8(%ebp), %eax # get argv

    cmp $2, %eax
    jge argparse_contains_filename

    argparse_syntax:
        lea log_syntax, %eax
        push %eax
        call printf

        addl $4, %esp

        push $1
        jmp finish

    argparse_contains_filename:

        # retrieve argv
        mov 0xc(%ebp), %ebx

        # retrieve argv[1]
        push 0x4(%ebx)


        cmp $3, %eax
        jl argparse_finish

        # check if argv[1] == "-v"
        mov 0x8(%ebx), %ebx
        push %ebx
        lea argparse_verbose, %ebx
        push %ebx
        call strcmp

        addl $8, %esp

        cmp $0, %eax
        jne argparse_syntax

        movl $1, g_verbose

        lea log_verbose, %eax
        push %eax
        call printf

        addl $4, %esp

    argparse_finish:
        pop %eax
        ret

main:
    push %ebp
    mov %esp, %ebp

    call argparse

    call read_source_file


    push $0
finish:
    call exit
