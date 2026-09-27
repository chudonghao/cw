; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names floating_arithmetic.cpp -o -
; ModuleID = 'floating_arithmetic.cpp'
source_filename = "floating_arithmetic.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z16SingleArithmeticff(float noundef %left, float noundef %right) #0 {
entry:
  %left.addr = alloca float, align 4
  %right.addr = alloca float, align 4
  store float %left, ptr %left.addr, align 4
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %left.addr, align 4
  %1 = load float, ptr %right.addr, align 4
  %fneg = fneg float %1
  %add = fadd float %0, %fneg
  %2 = load float, ptr %left.addr, align 4
  %3 = load float, ptr %right.addr, align 4
  %sub = fsub float %2, %3
  %mul = fmul float %add, %sub
  %4 = load float, ptr %right.addr, align 4
  %div = fdiv float %mul, %4
  ret float %div
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z16DoubleArithmeticdd(double noundef %left, double noundef %right) #0 {
entry:
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %fneg = fneg double %1
  %add = fadd double %0, %fneg
  %2 = load double, ptr %left.addr, align 8
  %3 = load double, ptr %right.addr, align 8
  %sub = fsub double %2, %3
  %mul = fmul double %add, %sub
  %4 = load double, ptr %right.addr, align 8
  %div = fdiv double %mul, %4
  ret double %div
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z11MultiplyAddddd(double noundef %left, double noundef %right, double noundef %addend) #0 {
entry:
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  %addend.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  store double %addend, ptr %addend.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %mul = fmul double %0, %1
  %2 = load double, ptr %addend.addr, align 8
  %add = fadd double %mul, %2
  ret double %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z7Groupedfff(float noundef %first, float noundef %second, float noundef %third) #0 {
entry:
  %first.addr = alloca float, align 4
  %second.addr = alloca float, align 4
  %third.addr = alloca float, align 4
  store float %first, ptr %first.addr, align 4
  store float %second, ptr %second.addr, align 4
  store float %third, ptr %third.addr, align 4
  %0 = load float, ptr %first.addr, align 4
  %1 = load float, ptr %second.addr, align 4
  %2 = load float, ptr %third.addr, align 4
  %add = fadd float %1, %2
  %add1 = fadd float %0, %add
  ret float %add1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z16PositiveInfinityv() #0 {
entry:
  ret double +inf
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z16NegativeInfinityv() #0 {
entry:
  ret float -inf
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z8Overflowv() #0 {
entry:
  ret double +inf
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z17NegativeUnderflowv() #0 {
entry:
  ret double -0.000000e+00
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z16GradualUnderflowv() #0 {
entry:
  ret float f0x00400000
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z13RoundEachStepv() #0 {
entry:
  ret float 0.000000e+00
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
