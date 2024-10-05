.globl main

.section .data
TEST_FIRST_VALUE: .asciz "first value\0"
TEST_SECOND_VALUE: .asciz "second value\0"


.section .text

fail_test:
    push $1
    call exit


main:
    push %ebp
    mov %esp, %ebp
    sub $4, %esp

    ## sanity check creation
    lea TEST_FIRST_VALUE, %eax
    push %eax # set value
    call tmbl_node_create
    addl $4, %esp

    mov %eax, -4(%ebp) # store list

    # check head and tail are correct
    mov (%eax), %ebx # tail
    cmp 4(%eax), %ebx # tail and head should be the same single node
    jne fail_test

    # check length is correct
    mov 8(%eax), %ebx # length
    cmp $1, %ebx
    jne fail_test

    # check value
    mov (%eax), %ebx # tail
    mov 4(%ebx), %ebx # value
    lea TEST_FIRST_VALUE, %ecx
    cmp %ecx, %ebx
    jne fail_test

    ## append sanity check

    lea TEST_SECOND_VALUE, %ebx
    push %ebx # append value
    push %eax
    call tmbl_node_append
    addl $8, %esp

    # check tail points to head
    mov -4(%ebp), %eax # load list
    mov (%eax), %ebx # tail
    mov 8(%ebx), %ebx # tail = tail->next
    mov 4(%eax), %ecx # head
    cmp %ebx, %ecx
    jne fail_test

    # check head value 
    lea TEST_SECOND_VALUE, %edx
    mov 4(%ecx), %ebx # head->value
    cmp %edx, %ebx
    jne fail_test

    # check list length is 2
    mov 8(%eax), %ebx # length
    cmp $2, %ebx
    jne fail_test


    mov -4(%ebp), %eax # load list
    push %eax
    call tmbl_node_print
    addl $4, %esp

    mov $0, %eax

    leave
    ret