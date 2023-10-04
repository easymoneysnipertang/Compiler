	.arch armv7-a
	.fpu vfpv3-d16
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 1
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"fib.c"
	.text
	.align	1
	.global	fib
	.syntax unified
	.thumb
	.thumb_func
	.type	fib, %function
fib:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	cmp	r0, #1
	bgt	.L8
	movs	r0, #1
	bx	lr
.L8:
	push	{r3, r4, r5, lr}
	mov	r4, r0
	subs	r0, r0, #1
	bl	fib(PLT)
	mov	r5, r0
	subs	r0, r4, #2
	bl	fib(PLT)
	add	r0, r0, r5
	pop	{r3, r4, r5, pc}
	.size	fib, .-fib
	.section	.rodata.str1.4,"aMS",%progbits,1
	.align	2
.LC0:
	.ascii	"%d\000"
	.align	2
.LC1:
	.ascii	"fib(%d) = %d\012\000"
	.text
	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, lr}
	ldr	r4, .L11
.LPIC0:
	add	r4, pc
	mov	r1, r4
	ldr	r0, .L11+4
.LPIC1:
	add	r0, pc
	bl	__isoc99_scanf(PLT)
	ldr	r4, [r4]
	mov	r0, r4
	bl	fib(PLT)
	mov	r3, r0
	mov	r2, r4
	ldr	r1, .L11+8
.LPIC3:
	add	r1, pc
	movs	r0, #1
	bl	__printf_chk(PLT)
	movs	r0, #0
	pop	{r4, pc}
.L12:
	.align	2
.L11:
	.word	.LANCHOR0-(.LPIC0+4)
	.word	.LC0-(.LPIC1+4)
	.word	.LC1-(.LPIC3+4)
	.size	main, .-main
	.global	n
	.bss
	.align	2
	.set	.LANCHOR0,. + 0
	.type	n, %object
	.size	n, 4
n:
	.space	4
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",%progbits
