	.text
	.file	"main.c"
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	# 需要的空间减少
	leaq	4(%rsp), %rsi
	movl	$.L.str, %edi
	xorl	%eax, %eax
	callq	__isoc99_scanf@PLT
	movl	4(%rsp), %eax
	# 直接比较常数
	movl	$1, %esi
	cmpl	$2, %eax
	jl	.LBB0_3
# %bb.1:                                # %.preheader
	negl	%eax
	movl	$2, %ecx
	movl	$1, %esi
	.p2align	4, 0x90
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	# esi->f,ecx/rcx->i,eax/rax->-n
	imull	%ecx, %esi
	leal	(%rax,%rcx), %edx
	addl	$1, %edx
                                        # kill: def $ecx killed $ecx killed $rcx
	addl	$1, %ecx
                                        # kill: def $ecx killed $ecx def $rcx
	# 循环跳出条件 edx=1
	cmpl	$1, %edx
	jne	.LBB0_2
.LBB0_3:
	# 输出
	movl	$.L.str.1, %edi
	xorl	%eax, %eax
	callq	printf@PLT
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"%d"
	.size	.L.str, 3

	.type	.L.str.1,@object                # @.str.1
.L.str.1:
	.asciz	"%d\n"
	.size	.L.str.1, 4

	.ident	"Ubuntu clang version 14.0.0-1ubuntu1.1"
	.section	".note.GNU-stack","",@progbits
