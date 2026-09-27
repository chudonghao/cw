; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names integer_conversion_flow.cpp -o -
; ModuleID = 'integer_conversion_flow.cpp'
source_filename = "integer_conversion_flow.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4BumpRa(ptr noundef nonnull align 1 dereferenceable(1) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %conv = sext i8 %1 to i32
  %add = add nsw i32 %conv, 1
  %conv1 = trunc i32 %add to i8
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5
  store i8 %conv1, ptr %2, align 1
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5
  %4 = load i8, ptr %3, align 1
  %conv2 = sext i8 %4 to i32
  ret i32 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z14ReadBeforeBumpRa(ptr noundef nonnull align 1 dereferenceable(1) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %before = alloca i32, align 4
  %after = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %conv = sext i8 %1 to i32
  store i32 %conv, ptr %before, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5
  %call = call noundef i32 @_Z4BumpRa(ptr noundef nonnull align 1 dereferenceable(1) %2)
  store i32 %call, ptr %after, align 4
  %3 = load i32, ptr %before, align 4
  %4 = load i32, ptr %after, align 4
  %add = add i32 %3, %4
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 2 dereferenceable(2) ptr @_Z6LocateRt(ptr noundef nonnull align 2 dereferenceable(2) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z15AssignConvertedRtx(ptr noundef nonnull align 2 dereferenceable(2) %value, i64 noundef %source) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %source.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %source, ptr %source.addr, align 8
  %0 = load i64, ptr %source.addr, align 8
  %conv = trunc i64 %0 to i16
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 2 dereferenceable(2) ptr @_Z6LocateRt(ptr noundef nonnull align 2 dereferenceable(2) %1)
  store i16 %conv, ptr %call, align 2
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z8ReadWideRKy(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = load i64, ptr %0, align 8
  ret i64 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z13TemporaryWidev() #0 {
entry:
  %ref.tmp = alloca i64, align 8
  store i64 -1, ptr %ref.tmp, align 8
  %call = call noundef i64 @_Z8ReadWideRKy(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp)
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i16 @_Z6Choosebhs(i1 noundef zeroext %flag, i8 noundef zeroext %left, i16 noundef signext %right) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i16, align 2
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i8 %left, ptr %left.addr, align 1
  store i16 %right, ptr %right.addr, align 2
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i8, ptr %left.addr, align 1
  %conv = zext i8 %1 to i32
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load i16, ptr %right.addr, align 2
  %conv1 = sext i16 %2 to i32
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %conv, %cond.true ], [ %conv1, %cond.false ]
  %conv2 = trunc i32 %cond to i16
  ret i16 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z11IntegerLooph(i8 noundef zeroext %limit) #0 {
entry:
  %limit.addr = alloca i8, align 1
  %index = alloca i8, align 1
  %total = alloca i16, align 2
  %step = alloca i8, align 1
  store i8 %limit, ptr %limit.addr, align 1
  store i8 0, ptr %index, align 1
  store i16 0, ptr %total, align 2
  store i8 1, ptr %step, align 1
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load i8, ptr %index, align 1
  %conv = zext i8 %0 to i32
  %1 = load i8, ptr %limit.addr, align 1
  %conv1 = zext i8 %1 to i32
  %cmp = icmp slt i32 %conv, %conv1
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %2 = load i16, ptr %total, align 2
  %conv2 = zext i16 %2 to i32
  %3 = load i8, ptr %index, align 1
  %conv3 = zext i8 %3 to i32
  %add = add nsw i32 %conv2, %conv3
  %conv4 = trunc i32 %add to i16
  store i16 %conv4, ptr %total, align 2
  %4 = load i8, ptr %index, align 1
  %conv5 = zext i8 %4 to i32
  %5 = load i8, ptr %step, align 1
  %conv6 = zext i8 %5 to i32
  %add7 = add nsw i32 %conv5, %conv6
  %conv8 = trunc i32 %add7 to i8
  store i8 %conv8, ptr %index, align 1
  br label %while.cond, !llvm.loop !8

while.end:                                        ; preds = %while.cond
  %6 = load i16, ptr %total, align 2
  ret i16 %6
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
!6 = !{i64 2}
!7 = !{i64 8}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
