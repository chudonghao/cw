; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fwrapv-pointer pointer_arithmetic.cpp -o -
; ModuleID = 'pointer_arithmetic.cpp'
source_filename = "pointer_arithmetic.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Pair = type { i64, i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7ForwardPim(ptr noundef %pointer, i64 noundef %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %add.ptr = getelementptr i32, ptr %0, i64 %1
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z6SignedlPKi(i64 noundef %count, ptr noundef %pointer) #0 {
entry:
  %count.addr = alloca i64, align 8
  %pointer.addr = alloca ptr, align 8
  store i64 %count, ptr %count.addr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  %add.ptr = getelementptr i32, ptr %1, i64 %0
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z8BackwardP4Pairm(ptr noundef %pointer, i64 noundef %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %idx.neg = sub i64 0, %1
  %add.ptr = getelementptr %struct.Pair, ptr %0, i64 %idx.neg
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z4RowsPA3_sl(ptr noundef %pointer, i64 noundef %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %idx.neg = sub i64 0, %1
  %add.ptr = getelementptr [3 x i16], ptr %0, i64 %idx.neg
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z6NestedPPim(ptr noundef %pointer, i64 noundef %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %add.ptr = getelementptr ptr, ptr %0, i64 %1
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z9CallbacksPPFivEm(ptr noundef %pointer, i64 noundef %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %add.ptr = getelementptr ptr, ptr %0, i64 %1
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z10InterfacesPM4PairKFivEl(ptr noundef %pointer, i64 noundef %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %add.ptr = getelementptr { i64, i64 }, ptr %0, i64 %1
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7AdvanceRPim(ptr noundef nonnull align 8 dereferenceable(8) %pointer, i64 noundef %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %2 = load ptr, ptr %1, align 8
  %add.ptr = getelementptr i32, ptr %2, i64 %0
  store ptr %add.ptr, ptr %1, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7RetreatRP4Pairl(ptr noundef nonnull align 8 dereferenceable(8) %pointer, i64 noundef %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %2 = load ptr, ptr %1, align 8
  %idx.neg = sub i64 0, %0
  %add.ptr = getelementptr %struct.Pair, ptr %2, i64 %idx.neg
  store ptr %add.ptr, ptr %1, align 8
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z9IncrementRPi(ptr noundef nonnull align 8 dereferenceable(8) %pointer) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %0, align 8
  %incdec.ptr = getelementptr i32, ptr %1, i32 1
  store ptr %incdec.ptr, ptr %0, align 8
  ret ptr %incdec.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z9DecrementRPKh(ptr noundef nonnull align 8 dereferenceable(8) %pointer) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %0, align 8
  %incdec.ptr = getelementptr i8, ptr %1, i32 -1
  store ptr %incdec.ptr, ptr %0, align 8
  ret ptr %1
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
