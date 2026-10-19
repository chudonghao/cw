; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names increment_arithmetic.cpp -o -
; ModuleID = 'increment_arithmetic.cpp'
source_filename = "increment_arithmetic.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z10SignedByteRa(ptr noundef nonnull align 1 dereferenceable(1) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %old = alloca i8, align 1
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  store i8 %1, ptr %old, align 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5
  %3 = load i8, ptr %2, align 1
  %conv = zext i8 %3 to i32
  %add = add i32 %conv, 1
  %conv1 = trunc i32 %add to i8
  %4 = load ptr, ptr %value.addr, align 8, !nonnull !5
  store i8 %conv1, ptr %4, align 1
  %5 = load i8, ptr %old, align 1
  ret i8 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z12UnsignedByteRh(ptr noundef nonnull align 1 dereferenceable(1) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %dec = add i8 %1, -1
  store i8 %dec, ptr %0, align 1
  ret i8 %dec
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i16 @_Z11SignedShortRs(ptr noundef nonnull align 2 dereferenceable(2) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i16, ptr %0, align 2
  %conv = zext i16 %1 to i32
  %add = add i32 %conv, 1
  %conv1 = trunc i32 %add to i16
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i16 %conv1, ptr %2, align 2
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %4 = load i16, ptr %3, align 2
  ret i16 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z13UnsignedShortRt(ptr noundef nonnull align 2 dereferenceable(2) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i16, ptr %0, align 2
  %dec = add i16 %1, -1
  store i16 %dec, ptr %0, align 2
  ret i16 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9SignedIntRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %old = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %old, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %3 = load i32, ptr %2, align 4
  %sub = sub i32 %3, 1
  %4 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  store i32 %sub, ptr %4, align 4
  %5 = load i32, ptr %old, align 4
  ret i32 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11UnsignedIntRj(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  %inc = add i32 %1, 1
  store i32 %inc, ptr %0, align 4
  ret i32 %inc
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z10SignedLongRx(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  %1 = load i64, ptr %0, align 8
  %sub = sub i64 %1, 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  store i64 %sub, ptr %2, align 8
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  %4 = load i64, ptr %3, align 8
  ret i64 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z12UnsignedLongRy(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  %1 = load i64, ptr %0, align 8
  %inc = add i64 %1, 1
  store i64 %inc, ptr %0, align 8
  ret i64 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z10SignedSizeRl(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  %1 = load i64, ptr %0, align 8
  %add = add i64 %1, 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  store i64 %add, ptr %2, align 8
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  %4 = load i64, ptr %3, align 8
  ret i64 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z12UnsignedSizeRm(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  %1 = load i64, ptr %0, align 8
  %dec = add i64 %1, -1
  store i64 %dec, ptr %0, align 8
  ret i64 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z7Float32Rf(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = load float, ptr %0, align 4
  %inc = fadd float %1, 1.000000e+00
  store float %inc, ptr %0, align 4
  ret float %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z7Float64Rd(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !8
  %1 = load double, ptr %0, align 8
  %dec = fadd double %1, -1.000000e+00
  store double %dec, ptr %0, align 8
  ret double %dec
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
!6 = !{i64 2}
!7 = !{i64 4}
!8 = !{i64 8}
