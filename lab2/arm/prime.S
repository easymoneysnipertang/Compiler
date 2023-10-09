 .arch armv7-a
.fpu vfpv3-d16
 @ 全局变量
 .comm a, 4 @ 要判断的素数
 .text
 .align 2
 @ 只读变量
 .section .rodata
 .align 2
 _str0:
 .ascii "%d\000" 
 .align 2
 _is_true:  @ 正确时的输出
 .ascii "%d IS a prime number\n\000"
 .align 2
 _is_false: @ 错误时的输出
 .ascii "%d IS NOT a prime number\n\000"
 .text
 .align	1
 .global is_prime
 .type	is_prime, %function
 is_prime: @ function is_prime(num)
    str fp, [sp, #-4]!      @ 栈帧调整
    mov fp, sp
    sub sp, sp, #12 

    @ 边界检查
    cmp r0, #2
    blt ._is_prime_false

    @ 开始循环判断是否整除
    @ 初始化
._init_for:
    mov r1, #2
._condition:
    mul r2,r1,r1
    cmp r0,r2               @ 比较num和i*i
    blt ._is_prime_true
    @ 循环体
._for_body:
    mov r3,r1               @ 保存i
    mov r4,r0               @ 保存num
    @ 计算num/i的余数
    mov r2, r0              @ dividend 
    mov r5, #0              @ quotient
    
._div_loop:
    cmp r2, r1              @ 比较dividend和divisor
    blt ._end_div_loop      @ 如果 dividend < divisor, 结束
    sub r2, r2, r1          
    add r5, r5, #1          
    b ._div_loop
    
._end_div_loop:
    mov r5, r2              @余数 Remainder.

    cmp r5,#0               @ 余数为0
    beq ._is_prime_false    @ 余数为0，不是素数

    @余数不为零，继续
    mov r1,r3
    mov r0,r4
._for_end_action:           @ for循环结束后的操作
    adds r1,r1,#1 @ i++
    b ._condition
._is_prime_true:            @ is_prime(num) == true
    mov r0, #1
    b ._exit_is_prime
._is_prime_false:           @ is_prime(num) == false
    mov r0, #0 
    b ._exit_is_prime
._exit_is_prime:            @ 函数退出，恢复栈帧
    mov sp, fp
    ldr fp, [sp], #4 
    bx lr 
.align	1
.global main
.type	main, %function
 main:
    push {fp, lr}
    add fp, sp, #4
    ldr r1, _data           @ r1 = &a
    ldr r0, _data+4         @ *r0 = "%d\000"
    bl __isoc99_scanf       @ scanf("%d", &a)
    ldr r3, _data           @ r3 = &a
    ldr r0, [r3]            @ r0 = a
    bl is_prime             @ r0 = result

    ldr r2, _data
    ldr r1, [r2]            @ 加载 a

    cmp r0, #1
    beq .is_true_main
._is_false_main:            @ "is not a prime"
    ldr r0, _data+12        
    bl printf 
    b ._exit_main
.is_true_main:              @ "is a prime"
    ldr r0, _data+8         
    bl printf 
._exit_main:
    mov r0, #0
    pop {fp, pc}            @ return 0

 _data:
    .word a
    .word _str0
    .word _is_true
    .word _is_false

.section .note.GNU-stack,"",%progbits 