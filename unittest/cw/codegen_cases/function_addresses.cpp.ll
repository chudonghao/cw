; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names function_addresses.cpp -o -
; ModuleID = 'function_addresses.cpp'
source_filename = "function_addresses.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z6Selecti(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z6Selectd(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  ret double %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z3Getv() #0 {
entry:
  ret ptr @_Z6Selectd
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef double @_Z6Invoked(double noundef %value) #1 {
entry:
  %value.addr = alloca double, align 8
  %callback = alloca ptr, align 8
  store double %value, ptr %value.addr, align 8
  store ptr @_Z6Selectd, ptr %callback, align 8
  %0 = load ptr, ptr %callback, align 8
  %1 = load double, ptr %value.addr, align 8
  %call = call noundef double %0(double noundef %1)
  ret double %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef double @_Z5ApplyPFddEd(ptr noundef %callback, double noundef %value) #1 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca double, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load double, ptr %value.addr, align 8
  %call = call noundef double %0(double noundef %1)
  ret double %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef double @_Z4Passv() #1 {
entry:
  %call = call noundef double @_Z5ApplyPFddEd(ptr noundef @_Z6Selectd, double noundef 2.500000e+00)
  ret double %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7Forwardv() #0 {
entry:
  ret ptr @_Z5Lateri
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5Lateri(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  ret i32 %0
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
