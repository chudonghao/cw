; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names assignment_evaluation.cpp -o -
; ModuleID = 'assignment_evaluation.cpp'
source_filename = "assignment_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z14MutatingTargetRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 73, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z15AssignmentOrderv() #0 {
entry:
  %value = alloca i32, align 4
  store i32 11, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z14MutatingTargetRi(ptr noundef nonnull align 4 dereferenceable(4) %value)
  store i32 %0, ptr %call, align 4
  %1 = load i32, ptr %value, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6TargetRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z10AssignOnceRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6TargetRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 17, ptr %call, align 4
  ret ptr %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z6ChangeRb(ptr noundef nonnull align 1 dereferenceable(1) %flag) #0 {
entry:
  %flag.addr = alloca ptr, align 8
  store ptr %flag, ptr %flag.addr, align 8
  %0 = load ptr, ptr %flag.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %loadedv = icmp ne i8 %1, 0
  %lnot = xor i1 %loadedv, true
  %2 = load ptr, ptr %flag.addr, align 8, !nonnull !5
  %storedv = zext i1 %lnot to i8
  store i8 %storedv, ptr %2, align 1
  ret i32 17
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z21ConditionalAssignmentb(i1 noundef zeroext %flag) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 1, ptr %left, align 4
  store i32 2, ptr %right, align 4
  %call = call noundef i32 @_Z6ChangeRb(ptr noundef nonnull align 1 dereferenceable(1) %flag.addr)
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %left, %cond.true ], [ %right, %cond.false ]
  store i32 %call, ptr %cond, align 4
  %1 = load i8, ptr %flag.addr, align 1
  %loadedv1 = icmp ne i8 %1, 0
  br i1 %loadedv1, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.end
  %2 = load i32, ptr %left, align 4
  br label %cond.end4

cond.false3:                                      ; preds = %cond.end
  %3 = load i32, ptr %right, align 4
  br label %cond.end4

cond.end4:                                        ; preds = %cond.false3, %cond.true2
  %cond5 = phi i32 [ %2, %cond.true2 ], [ %3, %cond.false3 ]
  ret i32 %cond5
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
