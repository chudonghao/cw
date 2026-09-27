; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names conditional_reference.cpp -o -
; ModuleID = 'conditional_reference.cpp'
source_filename = "conditional_reference.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 1 dereferenceable(1) ptr @_Z13SelectMutablebRbS_(i1 noundef zeroext %flag, ptr noundef nonnull align 1 dereferenceable(1) %left, ptr noundef nonnull align 1 dereferenceable(1) %right) #0 {
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
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  ret ptr %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z11ReadMutablebbb(i1 noundef zeroext %flag, i1 noundef zeroext %left, i1 noundef zeroext %right) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %left to i8
  store i8 %storedv1, ptr %left.addr, align 1
  %storedv2 = zext i1 %right to i8
  store i8 %storedv2, ptr %right.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef nonnull align 1 dereferenceable(1) ptr @_Z13SelectMutablebRbS_(i1 noundef zeroext %loadedv, ptr noundef nonnull align 1 dereferenceable(1) %left.addr, ptr noundef nonnull align 1 dereferenceable(1) %right.addr)
  %1 = load i8, ptr %call, align 1
  %loadedv3 = icmp ne i8 %1, 0
  ret i1 %loadedv3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 1 dereferenceable(1) ptr @_Z10SelectCopybRKbS0_(i1 noundef zeroext %flag, ptr noundef nonnull align 1 dereferenceable(1) %left, ptr noundef nonnull align 1 dereferenceable(1) %right) #0 {
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
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  ret ptr %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z8ReadCopybbb(i1 noundef zeroext %flag, i1 noundef zeroext %left, i1 noundef zeroext %right) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %left to i8
  store i8 %storedv1, ptr %left.addr, align 1
  %storedv2 = zext i1 %right to i8
  store i8 %storedv2, ptr %right.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef nonnull align 1 dereferenceable(1) ptr @_Z10SelectCopybRKbS0_(i1 noundef zeroext %loadedv, ptr noundef nonnull align 1 dereferenceable(1) %left.addr, ptr noundef nonnull align 1 dereferenceable(1) %right.addr)
  %1 = load i8, ptr %call, align 1
  %loadedv3 = icmp ne i8 %1, 0
  ret i1 %loadedv3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 1 dereferenceable(1) ptr @_Z10SelectMovebObS_(i1 noundef zeroext %flag, ptr noundef nonnull align 1 dereferenceable(1) %left, ptr noundef nonnull align 1 dereferenceable(1) %right) #0 {
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
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  ret ptr %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z8ReadMovebbb(i1 noundef zeroext %flag, i1 noundef zeroext %left, i1 noundef zeroext %right) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %left to i8
  store i8 %storedv1, ptr %left.addr, align 1
  %storedv2 = zext i1 %right to i8
  store i8 %storedv2, ptr %right.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef nonnull align 1 dereferenceable(1) ptr @_Z10SelectMovebObS_(i1 noundef zeroext %loadedv, ptr noundef nonnull align 1 dereferenceable(1) %left.addr, ptr noundef nonnull align 1 dereferenceable(1) %right.addr)
  %1 = load i8, ptr %call, align 1
  %loadedv3 = icmp ne i8 %1, 0
  ret i1 %loadedv3
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
