; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names floating_types.cpp -o -
; ModuleID = 'floating_types.cpp'
source_filename = "floating_types.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z6Singlef(float noundef %value) #0 {
entry:
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  ret float %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z6Doubled(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  ret double %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z4ReadRKd(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load double, ptr %0, align 8
  ret double %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRf(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6AssignRfd(ptr noundef nonnull align 4 dereferenceable(4) %target, double noundef %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca double, align 8
  store ptr %target, ptr %target.addr, align 8
  store double %source, ptr %source.addr, align 8
  %0 = load double, ptr %source.addr, align 8
  %conv = fptrunc double %0 to float
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !7
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRf(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store float %conv, ptr %call, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z7Forwardf(float noundef %value) #0 {
entry:
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %conv = fpext float %0 to double
  %call = call noundef double @_Z6Doubled(double noundef %conv)
  ret double %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z9Temporaryv() #0 {
entry:
  %ref.tmp = alloca double, align 8
  store double 5.000000e-01, ptr %ref.tmp, align 8
  %call = call noundef double @_Z4ReadRKd(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp)
  ret double %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z8ReadMoveOf(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = load float, ptr %0, align 4
  ret float %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z9MoveLocalv() #0 {
entry:
  %value = alloca float, align 4
  store float 2.500000e+00, ptr %value, align 4
  %call = call noundef float @_Z8ReadMoveOf(ptr noundef nonnull align 4 dereferenceable(4) %value)
  ret float %call
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
!6 = !{i64 8}
!7 = !{i64 4}
