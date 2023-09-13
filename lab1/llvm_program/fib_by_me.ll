define i32 @main(){
    ; 声明变量
    %1 = alloca i32, align 4
    %2 = alloca i32, align 4
    %3 = alloca i32, align 4
    %4 = alloca i32, align 4
    %5 = alloca i32, align 4
    ; 赋值
    store i32 0, i32* %1, align 4
    store i32 1, i32* %2, align 4
    store i32 1, i32* %3, align 4
    ; scanf & printf
    %6 = call i32 (i8*, ...) @__isoc99_scanf(i8* noundef getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i64 0, i64 0), i32* noundef %5)
    %7 = load i32, i32* %1, align 4
    %8 = load i32, i32* %2, align 4
    %9 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([7 x i8], [7 x i8]* @.str.1, i64 0, i64 0), i32 noundef %7, i32 noundef %8)
    br label %10
10:
    ; while(i<n)
    %11 = load i32, i32* %3, align 4
    %12 = load i32, i32* %5, align 4
    %13 = icmp slt i32 %11, %12
    br i1 %13, label %14, label 17
14:
    ; 循环内部
    %15 = load i32, i32* %2, align 4  ; t=b
    store i32 %16, i32* %4, align 4
    %16 = load i32, i32* %2, align 4  ; b=a+b
    %17 = load i32, i32* %3, align 4
    %18 = add nsw i32 %16,%17
    store i32 %18, i32* %2, align 4
    %19 = load i32, i32* %2, align 4  ; printf
    %20 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([7 x i8], [7 x i8]* @.str.2, i64 0, i64 0), i32 noundef %19)
    %21 = load i32, i32* %4, align 4  ; a=t
    store i32 %21, i32* %1, align 4
    %22 = load i32, i32* %3, align 4  ; i=i+1
    %23 = add nsw i32 22, 1
    store i32 %23, i32* %3, align 4
    br label %10, !llvm.loop !?   
24:
    ret i32 0
}