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
LENXLINE_STATEMENT_END: .int -1

.section .text
.extern printf

.extern tmbl_node_create
.extern tmbl_node_add_next
.extern tmbl_node_verbose

tmbl_lexline:
    push %ebp
    mov %esp, %ebp
    sub $4, %esp
    
    mov 0x8(%ebp), %eax # src
    mov 0xc(%ebp), %ebx # src length
    mov 0x10(%ebp), %ecx # statements list


    mov %eax, -4(%ebp) # source start pointer

    statement_loop:
        mov %eax, %edx # token start pointer

        cmp $'\n', %eax
        je line_end
        cmp $' ', %eax
        je token_end
        
        line_end:
            mov LENXLINE_STATEMENT_END, %eax
            mov %eax, %edx
            inc %edx

            # create another tokens list
            push $1
            push %ecx
            call tmbl_node_add_next
            addl $8, %esp

            mov %eax, %ecx
            mov %edx, %eax
            jmp continue

        token_end:
            movl $0, (%eax) # null terminate token instead of space

            push %edx # null-terminated token
            mov 4(%ecx), %edx
            push %edx
            call tmbl_node_add_next
            addl $8, %esp

        continue:
            inc %eax
            mov %eax, %edx # new src pointer
            subl -4(%ebp), %edx # get index from src start
            cmp %ebx, %edx # check if finished

            jle statement_loop
            
        mov $0, %eax
        ret


.global tmbl_lex
tmbl_lex:
    # params src pointer, src length
    enter $4, $0 # space for statements list

    # list of statements
    push $0
    call tmbl_node_create
    addl $4, %esp

    mov %eax, -4(%ebp) # store statements[]

    # list of tokens
    push $1
    call tmbl_node_create
    addl $4, %esp

    mov -4(%ebp), %ebx # load statements[]
    mov %eax, 4(%ebx) # statements[0].value = &tokens_list
    
    mov -4(%ebp), %ecx # load statements list
    push %ecx
    mov 0xc(%ebp), %ebx # src length
    push %ebx
    mov 0x8(%ebp), %eax # src
    push %eax
    call tmbl_lexline
    addl $0xc, %esp

    mov -4(%ebp), %ecx
    mov 4(%ecx), %ecx # first list of tokens
    call tmbl_node_verbose 
    addl $4, %esp

    leave
    ret