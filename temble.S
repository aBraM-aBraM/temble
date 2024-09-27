.globl main

.section .bss

.section .data
g_verbose: .int 0

CSTRUCT_STAT_ST_SIZE_OFFSET: .int 44

argparse_verbose: .asciz "-v"
LOG_VERBOSE: .asciz "running verbose\n"
LOG_FILESIZE: .asciz "source filesize: %d\n"
LOG_SOURCECODE: .asciz "source code:\n%s"
LOG_SYNTAX: .asciz  "syntax: ./temble <source-file> [-v]\n"

.section .text
.extern open
.extern read
.extern fstat
.extern exit
.extern printf
.extern perror
.extern strcmp
.extern malloc
.extern free


fatal_errno:
    push $0
    call perror 
    push $1
    jmp finish

verbose_log:
    # calls printf if verbose
    cmpl $1, g_verbose
    jne verbose_log_finish

    jmp printf # tail call optimiziations

    verbose_log_finish:
        ret

read_src:
    # open file to compile
    # expects filename in %eax
    # returns file content in %eax (allocated via malloc)
    
    ENTER $92, $0 # 88 = fstat struct size, 4 = fd

    # open file
    push $0 # readonly
    push %eax
    call open

    addl $8, %esp 

    # check fd
    cmp $0, %eax
    je fatal_errno

    # fstat file
    mov %eax, -4(%ebp) # save fd

    push %esp # ebp - 88(struct fstat) - 4(fd)
    push %eax
    call fstat

    addl $8, %esp

    cmp $0, %eax
    jne fatal_errno

    movl 44(%esp), %eax # get filesize

    lea LOG_FILESIZE, %ebx
    push %eax
    push %ebx
    call verbose_log
    
    addl $8, %esp

    # malloc file content

    movl 44(%esp), %eax # get filesize
    push %eax
    call malloc
    addl $4, %esp

    cmp $0, %eax
    je fatal_errno

    mov %eax, -8(%ebp) # save filesize overriding stat struct (don't need it anymore) 

    # read content
    mov -4(%ebp), %eax # get fd

    mov -8(%ebp), %ebx
    push $4096 # count 
    push %ebx  # buf
    push %eax  # fd
    call read

    addl $12, %esp

    cmp $-1, %eax
    je fatal_errno

    # print source on verbose
    mov -8(%ebp), %eax
    lea LOG_SOURCECODE, %ebx
    push %eax
    push %ebx
    call verbose_log 
    addl $4, %esp

    mov -8(%ebp), %eax
    read_src_finish:
    leave
    ret

argparse:
    # checks that a filename argument was given
    # returns filename in %eax

    mov 0x8(%ebp), %eax # get argv

    cmp $2, %eax
    jge argparse_contains_filename

    argparse_syntax:
        lea LOG_SYNTAX, %eax
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

        lea LOG_VERBOSE, %eax
        push %eax
        call verbose_log

        addl $4, %esp

    argparse_finish:
        pop %eax
        ret


main:
    push %ebp
    mov %esp, %ebp

    call argparse

    call read_src

    push %eax
    call free
    addl $4, %esp

    push $0
finish:
    call exit
