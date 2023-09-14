	.text
	.file	"prime.ll"
	.globl	isPrime                         # -- Begin function isPrime
	.p2align	4, 0x90
	.type	isPrime,@function
isPrime:                                # @isPrime
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	cmpl	$1, %edi
	jg	.LBB0_3
# %bb.1:                                # %not_prime
	xorl	%eax, %eax
	jmp	.LBB0_2
.LBB0_3:                                # %check_divisors
	movq	%rsp, %rax
	leaq	-16(%rax), %rcx
	movq	%rcx, %rsp
	movl	$2, -16(%rax)
	movq	%rsp, %rax
	leaq	-16(%rax), %r8
	movq	%r8, %rsp
	movb	$1, -16(%rax)
	.p2align	4, 0x90
.LBB0_4:                                # %loop_check_divisors
                                        # =>This Inner Loop Header: Depth=1
	movl	(%rcx), %esi
	movl	%esi, %eax
	imull	%esi, %eax
	cmpl	%edi, %eax
	jg	.LBB0_8
# %bb.5:                                # %check_divisor
                                        #   in Loop: Header=BB0_4 Depth=1
	movl	%edi, %eax
	cltd
	idivl	%esi
	testl	%edx, %edx
	je	.LBB0_7
# %bb.6:                                # %update_divisor
                                        #   in Loop: Header=BB0_4 Depth=1
	incl	%esi
	movl	%esi, (%rcx)
	jmp	.LBB0_4
.LBB0_7:                                # %done_check_divisors_false
	movb	$0, (%r8)
.LBB0_8:                                # %done_check_divisors
	movb	(%r8), %al
.LBB0_2:                                # %not_prime
	movq	%rbp, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	isPrime, .Lfunc_end0-isPrime
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	subq	$16, %rsp
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -16
	leaq	12(%rsp), %rsi
	movl	$.Lin_str, %edi
	xorl	%eax, %eax
	callq	__isoc99_scanf@PLT
	movl	12(%rsp), %ebx
	movl	%ebx, %edi
	callq	isPrime@PLT
	testb	$1, %al
	je	.LBB1_2
# %bb.1:                                # %is_prime_branch
	movl	$.Ltrue_str, %edi
	jmp	.LBB1_3
.LBB1_2:                                # %not_prime_branch
	movl	$.Lfalse_str, %edi
.LBB1_3:                                # %out
	movl	%ebx, %esi
	xorl	%eax, %eax
	callq	printf@PLT
	xorl	%eax, %eax
	addq	$16, %rsp
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	.Lin_str,@object                # @in_str
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lin_str:
	.asciz	"%d"
	.size	.Lin_str, 3

	.type	.Ltrue_str,@object              # @true_str
.Ltrue_str:
	.asciz	"%d is prime.\n"
	.size	.Ltrue_str, 14

	.type	.Lfalse_str,@object             # @false_str
.Lfalse_str:
	.asciz	"%d is not prime.\n"
	.size	.Lfalse_str, 18

	.section	".note.GNU-stack","",@progbits
