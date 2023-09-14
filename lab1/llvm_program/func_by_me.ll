; ModuleID = 'func.c'
source_filename = "func.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define float @func(i32 %0,float %1){    ; 必须是%0
    %3 = alloca float, align 4          ; 定义float c
    ; debug: '%0' defined with type 'i32' but expected 'i32*'
    %4 = alloca i32, align 4            ; 必须把参数拿出来存
    store i32 %0, i32* %4, align 4
    %5 = alloca float, align 4
    store float %1, float* %5, align 4
    %6 = load i32, i32* %4, align 4     ; 操作前取值
    %7 = load float, float* %5, align 4
    %8 = sitofp i32 %6 to float         ; 类型转换
    %9 = fadd float %7, %8              ; 相加
    store float %9, float* %3, align 4  ; 存入c
    ; debug: '%3' defined with type 'float*' but expected 'float'
    %10 = load float, float* %3, align 4
    ret float %10                        ; 返回
}

define i32 @main(){
    %1 = alloca i32,align 4         ; 定义a
    store i32 1, i32* %1, align 4   ; 赋值
    %2 = alloca [2 x float], align 4; 定义数组
    ; 取出数组，赋值
    %3 = getelementptr inbounds [2 x float], [2 x float]* %2, i32 0, i32 0
    store float 1.5, float* %3, align 4
    ; 取出值做参数
    %4 = load i32, i32* %1, align 4
    %5 = getelementptr inbounds [2 x float], [2 x float]* %2, i32 0, i32 0
    ; debug: '%5' defined with type 'float*' but expected 'float'
    %6 = load float, float* %5, align 4
    ; 调用函数，赋值
    %7 = call float @func(i32 %4,float %6)
    %8 = getelementptr inbounds [2 x float], [2 x float]* %2, i32 0, i32 1
    store float %6, float* %8, align 4
    ret i32 0
}


attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}