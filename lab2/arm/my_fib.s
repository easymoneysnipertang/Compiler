    .arch armv7-a
    .global main
    .global fib

    .data
    n:     .word 0
    str0:  .asciz "%d"
    str1:  .asciz "fib(%d) = %d\n"

    .text
    .align 2

fib:
    push    {r4, lr}        @ 保存寄存器
    cmp     r0, #1          @ 比较n和1
    bgt     .L1
    mov     r0, #1          @ 直接返回 
    pop     {r4, pc}
.L1:
    sub     sp, sp, #8
    str     r0, [sp, #4]    @ 保存n
    sub     r0, r0, #1
    bl      fib             @ 递归调用fib(n-1)
    mov     r4, r0
    ldr     r0, [sp, #4]
    sub     r0, r0, #2
    bl      fib             @ 递归调用fib(n-2)
    add     r0, r0, r4
    add     sp, sp, #8      @ 恢复栈
    pop     {r4, pc}

main:
    push    {r4, lr}
    ldr     r1, =n          @ 读入n
    ldr     r0, =str0
    bl      scanf           @ scanf("%d", &n)
    ldr     r3, =n
    ldr     r0, [r3]
    bl      fib             @ fib(n)
	mov    	r2, r0
    ldr     r3, =n
	ldr    	r1, [r3]
    ldr     r0, =str1
    bl      printf          @ printf("fib(%d) = %d\n", n, fib(n))
    mov     r0, #0
    pop     {r4, pc}
