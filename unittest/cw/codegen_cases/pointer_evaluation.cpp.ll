; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names pointer_evaluation.cpp -o -
; ModuleID = 'pointer_evaluation.cpp'
source_filename = "pointer_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z3SetRPiS_(ptr noundef nonnull align 8 dereferenceable(8) %target, ptr noundef %next) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %next.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %next, ptr %next.addr, align 8
  %0 = load ptr, ptr %next.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  store ptr %0, ptr %1, align 8
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %2, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z19CompareBeforeChangeRPiS_(ptr noundef nonnull align 8 dereferenceable(8) %target, ptr noundef %next) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %next.addr = alloca ptr, align 8
  %before = alloca ptr, align 8
  %after = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %next, ptr %next.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %0, align 8
  store ptr %1, ptr %before, align 8
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %next.addr, align 8
  %call = call noundef ptr @_Z3SetRPiS_(ptr noundef nonnull align 8 dereferenceable(8) %2, ptr noundef %3)
  store ptr %call, ptr %after, align 8
  %4 = load ptr, ptr %before, align 8
  %5 = load ptr, ptr %after, align 8
  %cmp = icmp eq ptr %4, %5
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z6ChoosebPi(i1 noundef zeroext %flag, ptr noundef %pointer) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %pointer.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %pointer.addr, align 8
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ null, %cond.false ]
  ret ptr %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(8) ptr @_Z6SelectbRPiS0_(i1 noundef zeroext %flag, ptr noundef nonnull align 8 dereferenceable(8) %left, ptr noundef nonnull align 8 dereferenceable(8) %right) #0 {
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
define void @_Z13WriteSelectedbRPiS0_S_(i1 noundef zeroext %flag, ptr noundef nonnull align 8 dereferenceable(8) %left, ptr noundef nonnull align 8 dereferenceable(8) %right, ptr noundef %value) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  %2 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @_Z6SelectbRPiS0_(i1 noundef zeroext %loadedv, ptr noundef nonnull align 8 dereferenceable(8) %2, ptr noundef nonnull align 8 dereferenceable(8) %3)
  store ptr %0, ptr %call, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z6LocatePiRi(ptr noundef %pointer, ptr noundef nonnull align 4 dereferenceable(4) %count) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %count.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %count.addr, align 8, !nonnull !5, !align !7
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %pointer.addr, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4NextRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %4 = load i32, ptr %3, align 4
  ret i32 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z10AssignOncePiRi(ptr noundef %pointer, ptr noundef nonnull align 4 dereferenceable(4) %state) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %state.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %state, ptr %state.addr, align 8
  %0 = load ptr, ptr %state.addr, align 8, !nonnull !5, !align !7
  %call = call noundef i32 @_Z4NextRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %pointer.addr, align 8
  %2 = load ptr, ptr %state.addr, align 8, !nonnull !5, !align !7
  %call1 = call noundef ptr @_Z6LocatePiRi(ptr noundef %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  store i32 %call, ptr %call1, align 4
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
!6 = !{i64 8}
!7 = !{i64 4}
