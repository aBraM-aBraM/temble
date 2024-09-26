.globl main

.section .data
filename: .asciz    "example.txt"

.section .text

# receives exit code into ebx
exit:
    movl $1, %eax # exit syscal
    int $0x80

main:

    movl $5, %eax
    movl $filename, %ebx
    movl $0, %ecx
    int $0x80

    movl %eax, %ebx
    jmp exit

