; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names floating_literals.cpp -o -
; ModuleID = 'floating_literals.cpp'
source_filename = "floating_literals.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z11SingleTenthv() #0 {
entry:
  ret float 1.000000e-01
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z11DoubleTenthv() #0 {
entry:
  ret double 1.000000e-01
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z15SingleSubnormalv() #0 {
entry:
  ret float 1.401300e-45
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z15DoubleSubnormalv() #0 {
entry:
  ret double 4.940660e-324
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z9Underflowv() #0 {
entry:
  ret double 0.000000e+00
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z12NegativeZerov() #0 {
entry:
  ret float -0.000000e+00
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z11NegatedZerov() #0 {
entry:
  ret double 0.000000e+00
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z13WidenedSinglev() #0 {
entry:
  ret double f0x3FB99999A0000000
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
