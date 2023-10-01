	.arch armv7-a
    .comm n, 4				@ n
	.text
	.align	2

	.section	.rodata
	.align	2
_str0:							@ 输入提示
	.ascii	"%d\000"
	.align	2
_str1:							@ 输出结果
	.ascii	"fib(%d) = %d\012\000"

	.text
	.align	2

	.global	fib
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

	.global	main
main:
	push	{fp, lr}			    @ 保存寄存器
	add     fp, sp, #4				@ 设置栈帧
	ldr     r1, _bridge				@ r1 = &n
	ldr     r0, _bridge+4			@ *ro = str0
	bl	    __isoc99_scanf
	ldr	    r3, _bridge				@ &n
	ldr	    r0, [r3]				@ n
	bl	    fib						@ fib(n)
	mov	    r2, r0					@ r2 = fib(n)
    ldr     r3, _bridge
	ldr    	r1, [r3]                @ r1 = n
	ldr	    r0, _bridge+8			@ *ro = str1
	bl	    printf					@ printf
	mov 	r0, #0
	pop	    {fp, pc}

_bridge:
	.word	n
	.word	_str0
	.word	_str1

	.section	.note.GNU-stack,"",%progbits
