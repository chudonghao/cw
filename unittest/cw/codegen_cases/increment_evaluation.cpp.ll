; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names increment_evaluation.cpp -o -
; ModuleID = 'increment_evaluation.cpp'
source_filename = "increment_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Item = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %old = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %old, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %2, align 4
  %add = add i32 %3, 1
  %4 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %4, align 4
  %5 = load i32, ptr %old, align 4
  ret i32 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9DecrementRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %old = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %old, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %2, align 4
  %sub = sub i32 %3, 1
  %4 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 %sub, ptr %4, align 4
  %5 = load i32, ptr %old, align 4
  ret i32 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRiS_(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6PrefixRiS_(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %target = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRiS_(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  store ptr %call, ptr %target, align 8
  %2 = load ptr, ptr %target, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %3 = load ptr, ptr %target, align 8, !nonnull !5, !align !6
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7PostfixRiS_(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRiS_(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %call1 = call noundef i32 @_Z9DecrementRi(ptr noundef nonnull align 4 dereferenceable(4) %call)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4PairRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %left, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %1, align 4
  store i32 %2, ptr %right, align 4
  %3 = load i32, ptr %left, align 4
  %4 = load i32, ptr %right, align 4
  %add = add i32 %3, %4
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5MixedRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %1, align 4
  store i32 %2, ptr %left, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %3)
  store i32 %call1, ptr %right, align 4
  %4 = load i32, ptr %left, align 4
  %5 = load i32, ptr %right, align 4
  %add = add i32 %4, %5
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z14SelfAssignmentRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %right, align 4
  %1 = load i32, ptr %right, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 %1, ptr %2, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7ElementRA2_iRm(ptr noundef nonnull align 4 dereferenceable(8) %data, ptr noundef nonnull align 8 dereferenceable(8) %index) #0 {
entry:
  %data.addr = alloca ptr, align 8
  %index.addr = alloca ptr, align 8
  %old_index = alloca i64, align 8
  store ptr %data, ptr %data.addr, align 8
  store ptr %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %index.addr, align 8, !nonnull !5, !align !7
  %1 = load i64, ptr %0, align 8
  %inc = add i64 %1, 1
  store i64 %inc, ptr %0, align 8
  store i64 %1, ptr %old_index, align 8
  %2 = load ptr, ptr %data.addr, align 8, !nonnull !5, !align !6
  %3 = load i64, ptr %old_index, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %2, i64 0, i64 %3
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %arrayidx)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11ConditionalRiS_b(ptr noundef nonnull align 4 dereferenceable(4) %first, ptr noundef nonnull align 4 dereferenceable(4) %second, i1 noundef zeroext %choose) #0 {
entry:
  %first.addr = alloca ptr, align 8
  %second.addr = alloca ptr, align 8
  %choose.addr = alloca i8, align 1
  store ptr %first, ptr %first.addr, align 8
  store ptr %second, ptr %second.addr, align 8
  %storedv = zext i1 %choose to i8
  store i8 %storedv, ptr %choose.addr, align 1
  %0 = load i8, ptr %choose.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %first.addr, align 8, !nonnull !5, !align !6
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %second.addr, align 8, !nonnull !5, !align !6
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %cond)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z12ShortCircuitRib(ptr noundef nonnull align 4 dereferenceable(4) %value, i1 noundef zeroext %choose) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %choose.addr = alloca i8, align 1
  store ptr %value, ptr %value.addr, align 8
  %storedv = zext i1 %choose to i8
  store i8 %storedv, ptr %choose.addr, align 1
  %0 = load i8, ptr %choose.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %entry
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %cmp = icmp eq i32 %call, 1
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %2 = phi i1 [ false, %entry ], [ %cmp, %land.rhs ]
  ret i1 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7AddressRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9DecrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5ChainRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %2, align 4
  ret i32 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6AssignRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 5, ptr %1, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8CompoundRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %right, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %2, align 4
  %4 = load i32, ptr %right, align 4
  %add = add i32 %3, %4
  %5 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %5, align 4
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5FieldR4Item(ptr noundef nonnull align 4 dereferenceable(4) %item) #0 {
entry:
  %item.addr = alloca ptr, align 8
  store ptr %item, ptr %item.addr, align 8
  %0 = load ptr, ptr %item.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %value)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11DereferencePi(ptr noundef %pointer) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %call = call noundef i32 @_Z9DecrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7DiscardRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z9IncrementRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call2 = call noundef i32 @_Z9DecrementRi(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call3 = call noundef i32 @_Z9DecrementRi(ptr noundef nonnull align 4 dereferenceable(4) %3)
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
!6 = !{i64 4}
!7 = !{i64 8}
