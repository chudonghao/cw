; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names floating_evaluation.cpp -o -
; ModuleID = 'floating_evaluation.cpp'
source_filename = "floating_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z4BumpRf(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load float, ptr %0, align 4
  %add = fadd float %1, 1.000000e+00
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store float %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %4 = load float, ptr %3, align 4
  %conv = fpext float %4 to double
  ret double %conv
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z14ReadBeforeBumpRf(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %left = alloca double, align 8
  %right = alloca double, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load float, ptr %0, align 4
  %conv = fpext float %1 to double
  store double %conv, ptr %left, align 8
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef double @_Z4BumpRf(ptr noundef nonnull align 4 dereferenceable(4) %2)
  store double %call, ptr %right, align 8
  %3 = load double, ptr %left, align 8
  %4 = load double, ptr %right, align 8
  %add = fadd double %3, %4
  ret double %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z4Pairdd(double noundef %first, double noundef %second) #0 {
entry:
  %first.addr = alloca double, align 8
  %second.addr = alloca double, align 8
  store double %first, ptr %first.addr, align 8
  store double %second, ptr %second.addr, align 8
  %0 = load double, ptr %first.addr, align 8
  %1 = load double, ptr %second.addr, align 8
  %add = fadd double %0, %1
  ret double %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z13ArgumentOrderRf(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %first = alloca double, align 8
  %second = alloca double, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load float, ptr %0, align 4
  %conv = fpext float %1 to double
  store double %conv, ptr %first, align 8
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef double @_Z4BumpRf(ptr noundef nonnull align 4 dereferenceable(4) %2)
  store double %call, ptr %second, align 8
  %3 = load double, ptr %first, align 8
  %4 = load double, ptr %second, align 8
  %call1 = call noundef double @_Z4Pairdd(double noundef %3, double noundef %4)
  ret double %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z6Choosebfd(i1 noundef zeroext %flag, float noundef %left, double noundef %right) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca float, align 4
  %right.addr = alloca double, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store float %left, ptr %left.addr, align 4
  store double %right, ptr %right.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load float, ptr %left.addr, align 4
  %conv = fpext float %1 to double
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load double, ptr %right.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi double [ %conv, %cond.true ], [ %2, %cond.false ]
  ret double %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z3Sumi(i32 noundef %limit) #0 {
entry:
  %limit.addr = alloca i32, align 4
  %index = alloca i32, align 4
  %sum = alloca double, align 8
  store i32 %limit, ptr %limit.addr, align 4
  store i32 0, ptr %index, align 4
  store double 0.000000e+00, ptr %sum, align 8
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load i32, ptr %index, align 4
  %1 = load i32, ptr %limit.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %2 = load double, ptr %sum, align 8
  %3 = load i32, ptr %index, align 4
  %conv = sitofp i32 %3 to double
  %add = fadd double %2, %conv
  store double %add, ptr %sum, align 8
  %4 = load i32, ptr %index, align 4
  %add1 = add nsw i32 %4, 1
  store i32 %add1, ptr %index, align 4
  br label %while.cond, !llvm.loop !7

while.end:                                        ; preds = %while.cond
  %5 = load double, ptr %sum, align 8
  ret double %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6SelectbRfS_(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  ret ptr %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z11WriteChosenbRfS_d(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right, double noundef %value) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %value.addr = alloca double, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = fptrunc double %0 to float
  %1 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  %2 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6SelectbRfS_(i1 noundef zeroext %loadedv, ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  store float %conv, ptr %call, align 4
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
!7 = distinct !{!7, !8}
!8 = !{!"llvm.loop.mustprogress"}
