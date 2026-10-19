; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names compound_evaluation.cpp -o -
; ModuleID = 'compound_evaluation.cpp'
source_filename = "compound_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Item = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %target, i32 noundef %rhs) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %rhs.addr = alloca i32, align 4
  store ptr %target, ptr %target.addr, align 8
  store i32 %rhs, ptr %rhs.addr, align 4
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %2 = load i32, ptr %rhs.addr, align 4
  %add = add i32 %1, %2
  %3 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %3, align 4
  %4 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  ret ptr %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z8MultiplyRii(ptr noundef nonnull align 4 dereferenceable(4) %target, i32 noundef %rhs) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %rhs.addr = alloca i32, align 4
  store ptr %target, ptr %target.addr, align 8
  store i32 %rhs, ptr %rhs.addr, align 4
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %2 = load i32, ptr %rhs.addr, align 4
  %mul = mul i32 %1, %2
  %3 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  store i32 %mul, ptr %3, align 4
  %4 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  ret ptr %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRiS_(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 1)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6ChangeRiS_(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %source) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  store i32 9, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7CaptureRiS_(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %source) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %rhs = alloca i32, align 4
  %lhs = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %rhs, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6ChangeRiS_(ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  store ptr %call, ptr %lhs, align 8
  %4 = load ptr, ptr %lhs, align 8, !nonnull !5, !align !6
  %5 = load i32, ptr %rhs, align 4
  %call1 = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %4, i32 noundef %5)
  %6 = load i32, ptr %call1, align 4
  ret i32 %6
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z4OnceRiS_(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %rhs = alloca i32, align 4
  %lhs = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 2, ptr %0, align 4
  store i32 2, ptr %rhs, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRiS_(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  store ptr %call, ptr %lhs, align 8
  %3 = load ptr, ptr %lhs, align 8, !nonnull !5, !align !6
  %4 = load i32, ptr %rhs, align 4
  %call1 = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %3, i32 noundef %4)
  ret ptr %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z14ReadAfterRightRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %rhs = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 2, ptr %0, align 4
  store i32 2, ptr %rhs, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %rhs, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %1, i32 noundef %2)
  %3 = load i32, ptr %call, align 4
  ret i32 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z5ChainRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 2)
  %call1 = call noundef nonnull align 4 dereferenceable(4) ptr @_Z8MultiplyRii(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef 3)
  ret ptr %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z15RightAssociatedRiS_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %rhs = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z8MultiplyRii(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 2)
  %1 = load i32, ptr %call, align 4
  store i32 %1, ptr %rhs, align 4
  %2 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %rhs, align 4
  %call1 = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %2, i32 noundef %3)
  %4 = load i32, ptr %call1, align 4
  ret i32 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7AddressRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 2)
  ret ptr %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5FieldR4Item(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %value1, i32 noundef 3)
  %1 = load i32, ptr %call, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7ElementRA2_im(ptr noundef nonnull align 4 dereferenceable(8) %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %rhs = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %0, i64 0, i64 %1
  store i32 2, ptr %arrayidx, align 4
  store i32 2, ptr %rhs, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %3 = load i64, ptr %index.addr, align 8
  %arrayidx1 = getelementptr inbounds nuw [2 x i32], ptr %2, i64 0, i64 %3
  %4 = load i32, ptr %rhs, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %arrayidx1, i32 noundef %4)
  %5 = load i32, ptr %call, align 4
  ret i32 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z11ConditionalRiS_b(ptr noundef nonnull align 4 dereferenceable(4) %first, ptr noundef nonnull align 4 dereferenceable(4) %second, i1 noundef zeroext %choose) #0 {
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
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %cond, i32 noundef 3)
  ret ptr %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7DiscardRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z3AddRii(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 2)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %1, align 4
  %shl = shl i32 %2, 0
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 %shl, ptr %3, align 4
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
