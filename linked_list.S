
.section .data
LOG_NODE_FMT: .asciz " %x { %x [%s] %x } - "
LOG_NODE_LEN: .asciz "list length: %d\n"
LOG_NEWLINE: .asciz "\n"

.section .text

.extern malloc
.extern free
.extern printf

.extern tmbl_verbose_log

.global tmbl_node_create
tmbl_node_create:
    # creates node params (value: int)
    # tail: *node 4 bytes
    # head: *node 4 bytes
    # length: int 4 bytes
    push %ebp
    mov %esp, %ebp
    sub $4, %esp

    push $12
    call malloc
    addl $4, %esp

    movl %eax, -4(%ebp) # store list locally

    # allocating the first node
    # prev: *node 4 bytes
    # value: int  4 bytes
    # next: *node 4 bytes
    push $12
    call malloc
    add $4, %esp

    mov 8(%ebp), %ebx # input param value

    # node values
    movl $0, (%eax) # prev
    mov %ebx, 4(%eax) # value
    movl $0, 8(%eax) # next

    # list values
    mov -4(%ebp), %ebx
    mov %eax, (%ebx) # tail
    mov %eax, 4(%ebx) # head
    movl $1, 8(%ebx) # length

    movl -4(%ebp), %eax

    leave
    ret


.global tmbl_node_append
tmbl_node_append:
    # params (node*, next_value: int) -> eax = new-next-node
    push %ebp
    mov %esp, %ebp

    push $12
    call malloc
    add $4, %esp

    mov 0x8(%ebp), %ebx # input list

    # inc len
    mov 0x8(%ebx), %ecx # list length
    inc %ecx
    mov %ecx, 0x8(%ebx)

    mov 4(%ebx), %ecx # head
    mov %eax, 8(%ecx) # head->next = new
    mov %ecx, (%eax)  # new->prev = head
    movl $0, 8(%eax)   # new->next = 0
    mov %eax, 4(%ebx) # list->head = new

    mov 0xc(%ebp), %ebx # input value
    mov %ebx, 4(%eax) # new->value = value

    leave
    ret

.global tmbl_node_map
tmbl_node_map:
    # params list, func(node*)
    push %ebp
    mov %esp, %ebp
    sub $8, %esp

    mov 0x8(%ebp), %eax # list param    
    mov 8(%eax), %ecx # length
    mov %ecx, -0x8(%ebp) # store length local

    cmp $1, %ecx
    je tmbl_node_map_finish

    mov (%eax), %ebx # tail
    mov %ebx, -0x4(%ebp) # store current

    tmbl_node_map_loop:
        mov 0xc(%ebp), %edx # load map func
        push %ebx # current node
        call *%edx # func
        addl $4, %esp

        mov -0x4(%ebp), %ebx # load current
        mov 0x8(%ebx), %ebx # set current to next
        mov %ebx, -0x4(%ebp) # store current

        # dec counter
        mov -0x8(%ebp), %ecx # length
        dec %ecx
        mov %ecx, -0x8(%ebp) # store value
        cmp $0, %ecx
        jne tmbl_node_map_loop

    tmbl_node_map_finish:
        leave
        ret

_tmbl_node_print:
    push %ebp
    mov %esp, %ebp
    
    mov 0x8(%ebp), %eax

    # next
    mov 8(%eax), %ebx
    push %ebx

    # value
    mov 4(%eax), %ebx
    push %ebx

    # prev
    mov (%eax), %ebx
    push %ebx

    # addr
    push %eax

    # format
    lea LOG_NODE_FMT, %eax
    push %eax
    call printf
    addl $0x14, %esp

    leave
    ret

.global tmbl_node_print
tmbl_node_print:
    push %ebp
    mov %esp, %ebp

    mov 0x8(%ebp), %eax # list param

    mov 0x8(%eax), %ebx # list length
    push %ebx
    lea LOG_NODE_LEN, %ebx
    push %ebx
    call printf
    addl $8, %esp

    lea _tmbl_node_print, %ebx # print each node func
    push %ebx
    mov 0x8(%ebp), %eax # list param
    push %eax
    call tmbl_node_map    
    addl $8, %esp

    lea LOG_NEWLINE, %eax
    push %eax
    call printf
    add $4, %esp

    leave
    ret