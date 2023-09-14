; ModuleID = 'fib.c'
source_filename = "fib.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str.1 = private unnamed_addr constant [7 x i8] c"%d\0A%d\0A\00", align 1
@.str.2 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
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
    br i1 %13, label %14, label %24
14:
    ; 循环内部
    %15 = load i32, i32* %2, align 4  ; t=b
    %16 = load i32, i32* %2, align 4  ; b=a+b
    store i32 %16, i32* %4, align 4
    %17 = load i32, i32* %3, align 4
    %18 = add nsw i32 %16,%17
    store i32 %18, i32* %2, align 4
    %19 = load i32, i32* %2, align 4  ; printf
    %20 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([4 x i8], [4 x i8]* @.str.2, i64 0, i64 0), i32 noundef %19)
    %21 = load i32, i32* %4, align 4  ; a=t
    store i32 %21, i32* %1, align 4
    %22 = load i32, i32* %3, align 4  ; i=i+1
    %23 = add nsw i32 22, 1
    store i32 %23, i32* %3, align 4
    br label %10 
24:
    ret i32 0
}


declare i32 @__isoc99_scanf(i8* noundef, ...) #1

declare i32 @printf(i8* noundef, ...) #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}