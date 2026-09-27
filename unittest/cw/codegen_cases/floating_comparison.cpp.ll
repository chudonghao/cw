; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names floating_comparison.cpp -o -
; ModuleID = 'floating_comparison.cpp'
source_filename = "floating_comparison.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z5Equalff(float noundef %left, float noundef %right) #0 {
entry:
  %left.addr = alloca float, align 4
  %right.addr = alloca float, align 4
  store float %left, ptr %left.addr, align 4
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %left.addr, align 4
  %1 = load float, ptr %right.addr, align 4
  %cmp = fcmp oeq float %0, %1
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z8NotEqualdd(double noundef %left, double noundef %right) #0 {
entry:
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %cmp = fcmp une double %0, %1
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z4Lessff(float noundef %left, float noundef %right) #0 {
entry:
  %left.addr = alloca float, align 4
  %right.addr = alloca float, align 4
  store float %left, ptr %left.addr, align 4
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %left.addr, align 4
  %1 = load float, ptr %right.addr, align 4
  %cmp = fcmp olt float %0, %1
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z9LessEqualdd(double noundef %left, double noundef %right) #0 {
entry:
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %cmp = fcmp ole double %0, %1
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z7Greaterff(float noundef %left, float noundef %right) #0 {
entry:
  %left.addr = alloca float, align 4
  %right.addr = alloca float, align 4
  store float %left, ptr %left.addr, align 4
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %left.addr, align 4
  %1 = load float, ptr %right.addr, align 4
  %cmp = fcmp ogt float %0, %1
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z12GreaterEqualdd(double noundef %left, double noundef %right) #0 {
entry:
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %cmp = fcmp oge double %0, %1
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z9MixedLessid(i32 noundef %left, double noundef %right) #0 {
entry:
  %left.addr = alloca i32, align 4
  %right.addr = alloca double, align 8
  store i32 %left, ptr %left.addr, align 4
  store double %right, ptr %right.addr, align 8
  %0 = load i32, ptr %left.addr, align 4
  %conv = sitofp i32 %0 to double
  %1 = load double, ptr %right.addr, align 8
  %cmp = fcmp olt double %conv, %1
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z8NaNEqualv() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z11NaNNotEqualv() #0 {
entry:
  ret i1 true
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z7NaNLessv() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z12NaNLessEqualv() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z10NaNGreaterv() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z15NaNGreaterEqualv() #0 {
entry:
  ret i1 false
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z16SignedZerosEqualv() #0 {
entry:
  ret i1 true
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
