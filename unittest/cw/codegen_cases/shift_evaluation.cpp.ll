; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names shift_evaluation.cpp -o -
; ModuleID = 'shift_evaluation.cpp'
source_filename = "shift_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %4 = load i32, ptr %3, align 4
  ret i32 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z14LeftBeforeCallRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %left, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %2)
  store i32 %call, ptr %right, align 4
  %3 = load i32, ptr %left, align 4
  %4 = load i32, ptr %right, align 4
  %and = and i32 %4, 31
  %shl = shl i32 %3, %and
  ret i32 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z15RightBeforeCallRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %left, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %2)
  store i32 %call, ptr %right, align 4
  %3 = load i32, ptr %left, align 4
  %4 = load i32, ptr %right, align 4
  %and = and i32 %4, 31
  %shr = ashr i32 %3, %and
  ret i32 %shr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9BothCallsRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %left, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i32 %call1, ptr %right, align 4
  %2 = load i32, ptr %left, align 4
  %3 = load i32, ptr %right, align 4
  %and = and i32 %3, 31
  %shl = shl i32 %2, %and
  ret i32 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8ZeroLeftRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %and = and i32 %call, 31
  %shl = shl i32 0, %and
  ret i32 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9ZeroCountRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %left, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %mul = mul nsw i32 %call1, 32
  store i32 %mul, ptr %right, align 4
  %2 = load i32, ptr %left, align 4
  %3 = load i32, ptr %right, align 4
  %and = and i32 %3, 31
  %shr = ashr i32 %2, %and
  ret i32 %shr
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
