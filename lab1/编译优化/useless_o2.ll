; ModuleID = 'main_useless.c'
source_filename = "main_useless.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str.1 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

; Function Attrs: nofree nounwind uwtable
define dso_local i32 @main() local_unnamed_addr #0 {
  %1 = alloca i32, align 4
  %2 = bitcast i32* %1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %2) #4
  %3 = call i32 (i8*, ...) @__isoc99_scanf(i8* noundef getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i64 0, i64 0), i32* noundef nonnull %1)
  %4 = load i32, i32* %1, align 4, !tbaa !5
  %5 = icmp slt i32 %4, 2
  br i1 %5, label %75, label %6

6:                                                ; preds = %0
  %7 = add i32 %4, -1
  %8 = icmp ult i32 %7, 8
  br i1 %8, label %66, label %9

9:                                                ; preds = %6
  %10 = and i32 %7, -8
  %11 = or i32 %10, 2
  %12 = add i32 %10, -8
  %13 = lshr exact i32 %12, 3
  %14 = add nuw nsw i32 %13, 1
  %15 = and i32 %14, 3
  %16 = icmp ult i32 %12, 24
  br i1 %16, label %42, label %17

17:                                               ; preds = %9
  %18 = and i32 %14, 1073741820
  br label %19

19:                                               ; preds = %19, %17
  %20 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %17 ], [ %37, %19 ]
  %21 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %17 ], [ %38, %19 ]
  %22 = phi <4 x i32> [ <i32 2, i32 3, i32 4, i32 5>, %17 ], [ %39, %19 ]
  %23 = phi i32 [ 0, %17 ], [ %40, %19 ]
  %24 = add <4 x i32> %22, <i32 4, i32 4, i32 4, i32 4>
  %25 = mul <4 x i32> %20, %22
  %26 = mul <4 x i32> %21, %24
  %27 = add <4 x i32> %22, <i32 8, i32 8, i32 8, i32 8>
  %28 = add <4 x i32> %22, <i32 12, i32 12, i32 12, i32 12>
  %29 = mul <4 x i32> %25, %27
  %30 = mul <4 x i32> %26, %28
  %31 = add <4 x i32> %22, <i32 16, i32 16, i32 16, i32 16>
  %32 = add <4 x i32> %22, <i32 20, i32 20, i32 20, i32 20>
  %33 = mul <4 x i32> %29, %31
  %34 = mul <4 x i32> %30, %32
  %35 = add <4 x i32> %22, <i32 24, i32 24, i32 24, i32 24>
  %36 = add <4 x i32> %22, <i32 28, i32 28, i32 28, i32 28>
  %37 = mul <4 x i32> %33, %35
  %38 = mul <4 x i32> %34, %36
  %39 = add <4 x i32> %22, <i32 32, i32 32, i32 32, i32 32>
  %40 = add i32 %23, 4
  %41 = icmp eq i32 %40, %18
  br i1 %41, label %42, label %19, !llvm.loop !9

42:                                               ; preds = %19, %9
  %43 = phi <4 x i32> [ undef, %9 ], [ %37, %19 ]
  %44 = phi <4 x i32> [ undef, %9 ], [ %38, %19 ]
  %45 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %9 ], [ %37, %19 ]
  %46 = phi <4 x i32> [ <i32 1, i32 1, i32 1, i32 1>, %9 ], [ %38, %19 ]
  %47 = phi <4 x i32> [ <i32 2, i32 3, i32 4, i32 5>, %9 ], [ %39, %19 ]
  %48 = icmp eq i32 %15, 0
  br i1 %48, label %60, label %49

49:                                               ; preds = %42, %49
  %50 = phi <4 x i32> [ %55, %49 ], [ %45, %42 ]
  %51 = phi <4 x i32> [ %56, %49 ], [ %46, %42 ]
  %52 = phi <4 x i32> [ %57, %49 ], [ %47, %42 ]
  %53 = phi i32 [ %58, %49 ], [ 0, %42 ]
  %54 = add <4 x i32> %52, <i32 4, i32 4, i32 4, i32 4>
  %55 = mul <4 x i32> %50, %52
  %56 = mul <4 x i32> %51, %54
  %57 = add <4 x i32> %52, <i32 8, i32 8, i32 8, i32 8>
  %58 = add i32 %53, 1
  %59 = icmp eq i32 %58, %15
  br i1 %59, label %60, label %49, !llvm.loop !12

60:                                               ; preds = %49, %42
  %61 = phi <4 x i32> [ %43, %42 ], [ %55, %49 ]
  %62 = phi <4 x i32> [ %44, %42 ], [ %56, %49 ]
  %63 = mul <4 x i32> %62, %61
  %64 = call i32 @llvm.vector.reduce.mul.v4i32(<4 x i32> %63)
  %65 = icmp eq i32 %7, %10
  br i1 %65, label %75, label %66

66:                                               ; preds = %6, %60
  %67 = phi i32 [ 1, %6 ], [ %64, %60 ]
  %68 = phi i32 [ 2, %6 ], [ %11, %60 ]
  br label %69

69:                                               ; preds = %66, %69
  %70 = phi i32 [ %72, %69 ], [ %67, %66 ]
  %71 = phi i32 [ %73, %69 ], [ %68, %66 ]
  %72 = mul nsw i32 %70, %71
  %73 = add nuw i32 %71, 1
  %74 = icmp eq i32 %71, %4
  br i1 %74, label %75, label %69, !llvm.loop !14

75:                                               ; preds = %69, %60, %0
  %76 = phi i32 [ 1, %0 ], [ %64, %60 ], [ %72, %69 ]
  %77 = call i32 (i8*, ...) @printf(i8* noundef nonnull dereferenceable(1) getelementptr inbounds ([4 x i8], [4 x i8]* @.str.1, i64 0, i64 0), i32 noundef %76)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %2) #4
  ret i32 0
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nofree nounwind
declare noundef i32 @__isoc99_scanf(i8* nocapture noundef readonly, ...) local_unnamed_addr #2

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nofree nounwind
declare noundef i32 @printf(i8* nocapture noundef readonly, ...) local_unnamed_addr #2

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i32 @llvm.vector.reduce.mul.v4i32(<4 x i32>) #3

attributes #0 = { nofree nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { nofree nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nofree nosync nounwind readnone willreturn }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = distinct !{!9, !10, !11}
!10 = !{!"llvm.loop.mustprogress"}
!11 = !{!"llvm.loop.isvectorized", i32 1}
!12 = distinct !{!12, !13}
!13 = !{!"llvm.loop.unroll.disable"}
!14 = distinct !{!14, !10, !15, !11}
!15 = !{!"llvm.loop.unroll.runtime.disable"}
