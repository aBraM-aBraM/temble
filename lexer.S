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
.extern tmbl_node_append
.extern tmbl_node_print

tmbl_lexline:
    push %ebp
    mov %esp, %ebp
    sub $8, %esp
    
    mov 0x8(%ebp), %eax # src
    mov 0xc(%ebp), %ebx # src length
    mov 0x10(%ebp), %ecx # statements list


    mov %eax, -4(%ebp) # source start pointer
    mov %eax, -8(%ebp) # current token start ptr
    mov %eax, %edx # token start pointer

    statement_loop:

        cmpb $'\n', (%eax)
        je line_end
        cmpb $' ', (%eax)
        je token_end
        jmp continue

        line_end:
            inc %eax # src ptr after \n
            mov %eax, -8(%ebp) # token_ptr = src_ptr = char after newline

            # create another tokens list
            push $1
            push %ecx
            call tmbl_node_append
            addl $8, %esp

            mov %eax, %ecx # statement_list = statement_list->next
            mov -8(%ebp), %eax # load src_ptr
            jmp continue

        token_end:
            movl $0, (%eax) # null terminate token instead of space
            inc %eax # src ptr after ' '
            
            # setup first param
            mov -8(%ebp), %edx # load token ptr
            push %edx # null-terminated token

            # store new value            
            mov %eax, -8(%ebp) # token_ptr = src_ptr = char after space


            mov 4(%ecx), %edx # load tokens list
            push %edx
            call tmbl_node_append # TODO: improve to append rather than add-next maybe change lists to keep length
            addl $8, %esp

            mov -8(%ebp), %eax # load token_ptr to src ptr 

        continue:
            inc %eax
            mov %eax, %edx # new src pointer
            subl -4(%ebp), %edx # get index from src start
            mov 0xc(%ebp), %ebx # src length
            cmp %ebx, %edx # check if finished

            jle statement_loop
            
        mov $0, %eax
        leave
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
    call tmbl_node_print 
    addl $4, %esp

    leave
    ret