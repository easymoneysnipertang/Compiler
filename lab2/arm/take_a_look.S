	.arch armv7-a
	.fpu vfpv3-d16
	.file	"prime.c"
	.text
	.align	1
	.global	is_prime
	.type	is_prime, %function
is_prime:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r3, [r7, #4]
	cmp	r3, #1
	bgt	.L2
	movs	r3, #0
	b	.L3
.L2:
	movs	r3, #2
	str	r3, [r7, #12]
	b	.L4
.L6:
	ldr	r3, [r7, #4]
	ldr	r1, [r7, #12]
	mov	r0, r3
	bl	__aeabi_idivmod(PLT)
	mov	r3, r1
	cmp	r3, #0
	bne	.L5
	movs	r3, #0
	b	.L3
.L5:
	ldr	r3, [r7, #12]
	adds	r3, r3, #1
	str	r3, [r7, #12]
.L4:
	ldr	r3, [r7, #12]
	mul	r3, r3, r3
	ldr	r2, [r7, #4]
	cmp	r2, r3
	bge	.L6
	movs	r3, #1
.L3:
	mov	r0, r3
	adds	r7, r7, #16
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
	.size	is_prime, .-is_prime
	.section	.rodata
	.align	2
.LC0:
	.ascii	"%d\000"
	.align	2
.LC1:
	.ascii	"%d is a prime number\012\000"
	.align	2
.LC2:
	.ascii	"%d is not a prime number\012\000"
	.text
	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	ldr	r2, .L12
.LPIC3:
	add	r2, pc
	ldr	r3, .L12+4
	ldr	r3, [r2, r3]
	ldr	r3, [r3]
	str	r3, [r7, #4]
	mov	r3, #0
	mov	r3, r7
	mov	r1, r3
	ldr	r3, .L12+8
.LPIC0:
	add	r3, pc
	mov	r0, r3
	bl	__isoc99_scanf(PLT)
	ldr	r3, [r7]
	mov	r0, r3
	bl	is_prime(PLT)
	mov	r3, r0
	cmp	r3, #0
	beq	.L8
	ldr	r3, [r7]
	mov	r1, r3
	ldr	r3, .L12+12
.LPIC1:
	add	r3, pc
	mov	r0, r3
	bl	printf(PLT)
	b	.L9
.L8:
	ldr	r3, [r7]
	mov	r1, r3
	ldr	r3, .L12+16
.LPIC2:
	add	r3, pc
	mov	r0, r3
	bl	printf(PLT)
.L9:
	movs	r3, #0
	ldr	r1, .L12+20
.LPIC4:
	add	r1, pc
	ldr	r2, .L12+4
	ldr	r2, [r1, r2]
	ldr	r1, [r2]
	ldr	r2, [r7, #4]
	eors	r1, r2, r1
	mov	r2, #0
	beq	.L11
	bl	__stack_chk_fail(PLT)
.L11:
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
.L13:
	.align	2
.L12:
	.word	_GLOBAL_OFFSET_TABLE_-(.LPIC3+4)
	.word	__stack_chk_guard(GOT)
	.word	.LC0-(.LPIC0+4)
	.word	.LC1-(.LPIC1+4)
	.word	.LC2-(.LPIC2+4)
	.word	_GLOBAL_OFFSET_TABLE_-(.LPIC4+4)
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",%progbits
