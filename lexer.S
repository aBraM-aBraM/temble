.section .data
hello:  .asciz "hello from lexer\n"

.section .text
.extern printf

.global print_from_lexer

print_from_lexer:
    lea hello, %eax
    push %eax
    call printf
    ret

