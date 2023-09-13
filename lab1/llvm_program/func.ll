; ModuleID = 'func.c'
source_filename = "func.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local float @func(i32 noundef %0, float noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca float, align 4
  %5 = alloca float, align 4
  store i32 %0, i32* %3, align 4
  store float %1, float* %4, align 4
  %6 = load i32, i32* %3, align 4
  %7 = sitofp i32 %6 to float
  %8 = load float, float* %4, align 4
  %9 = fadd float %7, %8
  store float %9, float* %5, align 4
  %10 = load float, float* %5, align 4
  ret float %10
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [2 x float], align 4
  store i32 1, i32* %1, align 4
  %3 = getelementptr inbounds [2 x float], [2 x float]* %2, i64 0, i64 0
  store float 1.500000e+00, float* %3, align 4
  %4 = load i32, i32* %1, align 4
  %5 = getelementptr inbounds [2 x float], [2 x float]* %2, i64 0, i64 0
  %6 = load float, float* %5, align 4
  %7 = call float @func(i32 noundef %4, float noundef %6)
  %8 = getelementptr inbounds [2 x float], [2 x float]* %2, i64 0, i64 1
  store float %7, float* %8, align 4
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
