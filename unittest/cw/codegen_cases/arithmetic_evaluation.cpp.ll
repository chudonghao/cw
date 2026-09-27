; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names arithmetic_evaluation.cpp -o -
; ModuleID = 'arithmetic_evaluation.cpp'
source_filename = "arithmetic_evaluation.cpp"
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
define noundef i32 @_Z14ReadBeforeCallRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
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
  %add = add nsw i32 %3, %4
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z17CompareBeforeCallRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
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
  %cmp = icmp eq i32 %3, %4
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z10DivideOnceRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
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
  %div = sdiv i32 %2, %3
  ret i32 %div
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z19RemainderSideEffectRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret i32 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z18ConditionalDivisorRib(ptr noundef nonnull align 4 dereferenceable(4) %value, i1 noundef zeroext %flag) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %2, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %call, %cond.true ], [ %3, %cond.false ]
  store i32 %cond, ptr %left, align 4
  %4 = load i8, ptr %flag.addr, align 1
  %loadedv1 = icmp ne i8 %4, 0
  br i1 %loadedv1, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  br label %cond.end5

cond.false3:                                      ; preds = %cond.end
  %5 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call4 = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %5)
  br label %cond.end5

cond.end5:                                        ; preds = %cond.false3, %cond.true2
  %cond6 = phi i32 [ -1, %cond.true2 ], [ %call4, %cond.false3 ]
  store i32 %cond6, ptr %right, align 4
  %6 = load i32, ptr %left, align 4
  %7 = load i32, ptr %right, align 4
  %div = sdiv i32 %6, %7
  ret i32 %div
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z20ShortCircuitDivisionbii(i1 noundef zeroext %flag, i32 noundef %left, i32 noundef %right) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %entry
  %1 = load i32, ptr %left.addr, align 4
  %2 = load i32, ptr %right.addr, align 4
  %div = sdiv i32 %1, %2
  %cmp = icmp sgt i32 %div, 0
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %3 = phi i1 [ false, %entry ], [ %cmp, %land.rhs ]
  ret i1 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7Consumei(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z14DiscardAndPassRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %add = add nsw i32 %call, 1
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z4BumpRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %mul = mul nsw i32 %call1, 2
  %call2 = call noundef i32 @_Z7Consumei(i32 noundef %mul)
  ret i32 %call2
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
