.globl main

.section .bss
buffer: .space 4096

.section .data
filename: .asciz    "example.txt"


.section .text
.extern open
.extern read
.extern fstat
.extern exit
.extern printf
.extern strerror
.extern __errno_location

fatal_errno:
# prints errno using strerror
# and exits using %eax as exit code
    call __errno_location
    mov (%eax), %eax
    push %eax
    call strerror
    push %eax
    call printf

    push %eax
    jmp finish

main:
    push %ebp
    mov %esp, %ebp

    # open file to compile
    push $0 # readonly
    lea filename, %eax
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


    push $0
finish:
    call exit
