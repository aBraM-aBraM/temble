.section .data
hello:  .asciz "hello from lexer\n"

.align 4
tokens:
    .asciz "#\0"
    .asciz "func\0"
    .asciz "(\0"
    .asciz ")\0"
    .asciz ",\0"
    .asciz "return\0"
    .asciz "str\0"
    .asciz "int\0"
    .asciz "while\0"
    .asciz "if\0"
    .asciz "printf\0"
    .asciz ":\0"
    .asciz "\t\0"
    .asciz "+\0"
    .asciz "-\0"
    .asciz "*\0"
    .asciz "/\0"
    .asciz "=\0"
    .asciz "<\0"
    .asciz ">\0"
    .asciz "==\0"
    .asciz "asm\0"
token_count: .int 23

.section .text
.extern printf

.extern tmbl_node_create
.extern tmbl_node_add_next
.extern tmbl_node_verbose

tmbl_lexline:
    # tail call optimize
    # input:
    # %eax a list to fill tokens in the current line with
    # %ebx current line pointer

    mov %ebx, %edi # source code
    mov %eax, %ebx # token list

    xor %eax, %eax
    mov $'\n', %eax # value to compare to
    mov $0xFFFFFFFF, %ecx # infinite max loop count for repne scasb

    repne scasb # repeat until (%al=0) == (%edi)

    # _if you're here either end of file reached (not zero)
    # or '\n' == current byte (zero)
    jnz tmbl_lexline_no_newline

    dec %edi # after scasb edi is increased meaning we finished one byte after newline
    sub 4(%ebp), %edi # get index by removing base string addr

    mov %edi, %eax
    ret

    tmbl_lexline_no_newline:
        mov $1, %eax
        ret


.global tmbl_lex
tmbl_lex:
    enter $8, $0 # space for src (char*) and token list (node)

    mov 8(%ebp), %eax # src

    # list of statements
    push $0
    call tmbl_node_create
    addl $4, %esp

    mov %eax, -4(%ebp) # store statements list

    # list of tokens
    push $1
    call tmbl_node_create
    addl $4, %esp

    mov -4(%ebp), %ebx # load statements list
    mov %eax, 4(%ebx) # statements[0].value = &tokens_list

    mov 8(%ebp), %ebx # src
    # eax = tokens_list    
    call tmbl_lexline

    leave
    ret