; LLVM IR 
; check prime

@in_str = private unnamed_addr constant [3 x i8] c"%d\00",align 1
@true_str = private unnamed_addr constant [14 x i8] c"%d is prime.\0A\00",align 1
@false_str = private unnamed_addr constant [18 x i8] c"%d is not prime.\0A\00",align 1


define i1 @isPrime(i32 %n) {
entry:

    ; 检测<=1的情况
    %cmp1 = icmp sle i32 %n, 1
    br i1 %cmp1, label %not_prime, label %check_divisors

not_prime:
    ; 如果小于1，则不是素数
    ret i1 0

check_divisors:
    ; 初始化 divisor，is_prime
    %divisor = alloca i32
    store i32 2, i32* %divisor
    %is_prime = alloca i1
    store i1 true, i1* %is_prime

    ; 用循环检测是否能被2到根号n内的数整除
    br label %loop_check_divisors

loop_check_divisors:
    ; 循环头

    ; 当前因数与标志位
    %cur_divisor = load i32, i32* %divisor
    %cur_is_prime = load i1, i1* %is_prime

    ; 检查因子的平方是否大于n
    %sqr_divisor = mul nsw i32 %cur_divisor, %cur_divisor
    %flag = icmp sgt i32 %sqr_divisor, %n
    br i1 %flag, label %done_check_divisors, label %check_divisor

check_divisor:
    ; 检测n是否能被当前因数整除
    %remainder = srem i32 %n, %cur_divisor
    %divisible = icmp eq i32 %remainder, 0

    ; 能整除就退出
    br i1 %divisible, label %done_check_divisors_false, label %update_divisor

update_divisor:
    ; 将因数增大1
    %increse_divisor = add i32 %cur_divisor, 1
    store i32 %increse_divisor,i32* %divisor
    br label %loop_check_divisors
done_check_divisors_false:
    store i1 false, i1* %is_prime
    br label %done_check_divisors 
done_check_divisors:
    ; 结束检测，返回标志
    %is_prime_val = load i1, i1* %is_prime
    ret i1 %is_prime_val
}

define i32 @main() {
    ; 打印提示让用户输入
    %in_str = getelementptr [3 x i8], [3 x i8]* @in_str, i32 0, i32 0
    %input = alloca i32
    %length = call i32 (i8*, ...) @__isoc99_scanf(i8* noundef getelementptr inbounds ([3 x i8], [3 x i8]* @in_str, i64 0, i64 0), i32* noundef %input)
    %n = load i32, i32* %input
    %is_prime = call i1 @isPrime(i32 %n)

    ; 打印结果
    br i1 %is_prime, label %is_prime_branch,label %not_prime_branch
is_prime_branch:
    %true_s = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([14 x i8], [14 x i8]* @true_str, i64 0, i64 0), i32 noundef %n)
    br label %out
not_prime_branch:
    %false_s = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([18 x i8], [18 x i8]* @false_str, i64 0, i64 0), i32 noundef %n)
    br label %out
out:
    ret i32 0
}

declare i32 @__isoc99_scanf(i8* noundef, ...) #1

declare i32 @printf(i8* noundef, ...) #1