; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fwrapv-pointer pointer_arithmetic_evaluation.cpp -o -
; ModuleID = 'pointer_arithmetic_evaluation.cpp'
source_filename = "pointer_arithmetic_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z5CountRm(ptr noundef nonnull align 8 dereferenceable(8) %counter) #0 {
entry:
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %1 = load i64, ptr %0, align 8
  %add = add i64 %1, 1
  store i64 %add, ptr %0, align 8
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %3 = load i64, ptr %2, align 8
  ret i64 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(8) ptr @_Z6LocateRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %calls) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %calls.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %calls, ptr %calls.addr, align 8
  %0 = load ptr, ptr %calls.addr, align 8, !nonnull !5, !align !6
  %1 = load i64, ptr %0, align 8
  %add = add i64 %1, 1
  store i64 %add, ptr %0, align 8
  %2 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  ret ptr %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z11OffsetFirstRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %counter) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %offset = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i64 @_Z5CountRm(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store i64 %call, ptr %offset, align 8
  %1 = load i64, ptr %offset, align 8
  %2 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef nonnull align 8 dereferenceable(8) ptr @_Z6LocateRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %2, ptr noundef nonnull align 8 dereferenceable(8) %3)
  %4 = load ptr, ptr %call1, align 8
  %add.ptr = getelementptr i32, ptr %4, i64 %1
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z11SourceFirstRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %counter) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %offset = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i64 @_Z5CountRm(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store i64 %call, ptr %offset, align 8
  %1 = load i64, ptr %offset, align 8
  %2 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef nonnull align 8 dereferenceable(8) ptr @_Z6LocateRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %2, ptr noundef nonnull align 8 dereferenceable(8) %3)
  %4 = load ptr, ptr %call1, align 8
  %add.ptr = getelementptr i32, ptr %4, i64 %1
  store ptr %add.ptr, ptr %call1, align 8
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z3OldRPi(ptr noundef nonnull align 8 dereferenceable(8) %pointer) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %before = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %0, align 8
  %incdec.ptr = getelementptr i32, ptr %1, i32 1
  store ptr %incdec.ptr, ptr %0, align 8
  store ptr %1, ptr %before, align 8
  %2 = load ptr, ptr %before, align 8
  %3 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %4 = load ptr, ptr %3, align 8
  %cmp = icmp ne ptr %2, %4
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7DiscardRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %counter) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @_Z6LocateRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1)
  %2 = load ptr, ptr %call, align 8
  %incdec.ptr = getelementptr i32, ptr %2, i32 -1
  store ptr %incdec.ptr, ptr %call, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z8DistanceRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %counter) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %before = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @_Z6LocateRPiRm(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1)
  %2 = load ptr, ptr %call, align 8
  %incdec.ptr = getelementptr i32, ptr %2, i32 1
  store ptr %incdec.ptr, ptr %call, align 8
  store ptr %2, ptr %before, align 8
  %3 = load ptr, ptr %before, align 8
  %4 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %5 = load ptr, ptr %4, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %3 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %5 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = sdiv exact i64 %sub.ptr.sub, 4
  ret i64 %sub.ptr.div
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 4]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.5"}
!5 = !{}
!6 = !{i64 8}
