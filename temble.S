.globl main

.section .bss

.section .data
g_verbose: .int 0

CSTRUCT_STAT_ST_SIZE_OFFSET: .int 44

tmbl_argparse_verbose: .asciz "-v"
LOG_VERBOSE: .asciz "running verbose\n"
LOG_FILESIZE: .asciz "source filesize: %d\n"
LOG_SOURCECODE: .asciz "source code:\n%s"
LOG_READ_COUNT_MATCH: .asciz "read count %d smaller than filesize %d\n"
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

.extern tmbl_lex


fatal_errno:
    push $0
    call perror 
    push $1
    jmp finish

.global tmbl_verbose_log
tmbl_verbose_log:
    # calls printf if verbose
    cmpl $1, g_verbose
    jne tmbl_verbose_log_finish

    jmp printf # tail call optimiziations

    tmbl_verbose_log_finish:
        ret

tmbl_read_src:
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
    mov %eax, -8(%ebp) # save filesize {overriding stat struct because I don't need it anymore}

    lea LOG_FILESIZE, %ebx
    push %eax
    push %ebx
    call tmbl_verbose_log    
    addl $8, %esp


    # malloc file content

    movl -8(%ebp), %eax # get filesize
    push %eax
    call malloc
    addl $4, %esp

    cmp $0, %eax
    je fatal_errno

    mov %eax, -12(%ebp) # save buffer overriding stat struct (don't need it anymore) 

    # read content %eax already buf
    mov -4(%ebp), %ebx # fd
    mov -8(%ebp), %ecx # filesize
    
    push %ecx # count 
    push %eax # buf
    push %ebx # fd
    call read
    addl $12, %esp

    cmp $-1, %eax
    je fatal_errno

    mov -8(%ebp), %ecx # filesize
    cmp %eax, %ecx
    je tmbl_read_src_read_success

    lea LOG_READ_COUNT_MATCH, %ebx
    push %ecx
    push %eax
    push %ebx
    call printf
    addl $12, %esp

    push $1
    jmp finish

    tmbl_read_src_read_success:

    # print source on verbose 
    mov -12(%ebp), %eax
    lea LOG_SOURCECODE, %ebx
    push %eax
    push %ebx
    call tmbl_verbose_log 
    addl $4, %esp

    mov -12(%ebp), %eax # src
    mov -8(%ebp), %ebx # filesize
    tmbl_read_src_finish:
    leave
    ret

tmbl_argparse:
    # checks that a filename argument was given
    # returns filename in %eax

    mov 0x8(%ebp), %eax # get argv

    cmp $2, %eax
    jge tmbl_argparse_contains_filename

    tmbl_argparse_syntax:
        lea LOG_SYNTAX, %eax
        push %eax
        call printf

        addl $4, %esp

        push $1
        jmp finish

    tmbl_argparse_contains_filename:

        # retrieve argv
        mov 0xc(%ebp), %ebx

        # retrieve argv[1]
        push 0x4(%ebx)


        cmp $3, %eax
        jl tmbl_argparse_finish

        # check if argv[1] == "-v"
        mov 0x8(%ebx), %ebx
        push %ebx
        lea tmbl_argparse_verbose, %ebx
        push %ebx
        call strcmp

        addl $8, %esp

        cmp $0, %eax
        jne tmbl_argparse_syntax

        movl $1, g_verbose

        lea LOG_VERBOSE, %eax
        push %eax
        call tmbl_verbose_log

        addl $4, %esp

    tmbl_argparse_finish:
        pop %eax
        ret


main:
    enter $8, $0


    call tmbl_argparse

    call tmbl_read_src

    mov %eax, -4(%ebp) # save src
    mov %ebx, -8(%ebp) # save src filesize

    push %ebx
    push %eax
    call tmbl_lex
    addl $8, %esp

    mov -4(%ebp), %eax # free src
    push %eax
    call free
    addl $4, %esp

    push $0
finish:
    call exit
    leave