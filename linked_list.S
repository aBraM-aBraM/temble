
.section .data
LOG_NODE_FMT: .asciz "%x {%x [%s] %x } - "
LOG_NODE_LEN: .asciz "list length: %d\n"

.section .text

.extern malloc
.extern free

.extern tmbl_verbose_log

.global tmbl_node_create
tmbl_node_create:
    # creates node params (value: int)
    # prev: *node 4 bytes
    # value: *char 4 bytes
    # node: *node 4 bytes
    enter $4, $0

    push $12
    call malloc
    addl $4, %esp

    # values important for checking bounds
    movl $0, (%eax) # prev
    
    movl 8(%ebp), %ecx
    movl %ecx, 4(%eax) # value
    
    movl $0, 8(%eax) # next

    leave
    ret

.global tmbl_node_add_next
tmbl_node_add_next:
    # params (node*, next_value: int) -> eax = new-next-node
    enter $8, $0

    # input node into ebx
    mov 0x8(%ebp), %ebx

    # new node in eax with next_value
    mov 0xc(%ebp), %eax
    push %eax
    call tmbl_node_create
    addl $4, %esp

    mov %eax, 8(%ebx) # node->next = &new_node
    mov %ebx, (%eax) # new_node->prev = &node

    leave
    ret

.global tmbl_node_len
tmbl_node_len:
    # params (node*) -> eax = new-node
    enter $4, $0

    mov 0x8(%ebp), %eax
    mov $1, %ebx

    tml_node_len_loop:
        cmpl $0, 8(%eax)
        je tmbl_node_len_finish
        inc %ebx
        mov 8(%eax), %eax
        jmp tml_node_len_loop


    tmbl_node_len_finish:
        mov %ebx, %eax
        leave
        ret


.global tmbl_node_verbose
tmbl_node_verbose:
    # prints entire nodes on verbose
    # params (node*)
    enter $4, $0

    mov 8(%ebp), %eax # input node to eax
    mov %eax, -4(%ebp) # save current node locally

    push %eax
    call tmbl_node_len
    addl $4, %esp


    push %eax
    lea LOG_NODE_LEN, %ebx
    push %ebx
    call tmbl_verbose_log
    addl $8, %esp

    mov -4(%ebp), %eax

    tmbl_node_verbose_loop:

        # im anding with 0xff to get a simpler output
        # next
        mov 8(%eax), %ebx
        push %ebx
        # value
        mov 4(%eax), %ebx
        push %ebx
        # prev
        mov (%eax), %ebx
        push %ebx
        # node addr
        mov %eax, %ebx
        push %ebx
        lea LOG_NODE_FMT, %ebx
        push %ebx


        call tmbl_verbose_log
        addl $16, %esp
        
        mov -4(%ebp), %eax   # load local current node
        cmpl $0, 8(%eax) # has next?
        je tmbl_node_verbose_finish
        # save next locally
        mov 8(%eax), %eax
        mov %eax, -4(%ebp)
        jmp tmbl_node_verbose_loop

    tmbl_node_verbose_finish:
    leave
    ret
