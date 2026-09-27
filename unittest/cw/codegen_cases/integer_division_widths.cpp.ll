; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names integer_division_widths.cpp -o -
; ModuleID = 'integer_division_widths.cpp'
source_filename = "integer_division_widths.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z12ByteQuotientaa(i8 noundef signext %dividend, i8 noundef signext %divisor) #0 {
entry:
  %retval = alloca i8, align 1
  %dividend.addr = alloca i8, align 1
  %divisor.addr = alloca i8, align 1
  store i8 %dividend, ptr %dividend.addr, align 1
  store i8 %divisor, ptr %divisor.addr, align 1
  %0 = load i8, ptr %dividend.addr, align 1
  %conv = sext i8 %0 to i32
  %cmp = icmp eq i32 %conv, -128
  br i1 %cmp, label %land.lhs.true, label %if.end

land.lhs.true:                                    ; preds = %entry
  %1 = load i8, ptr %divisor.addr, align 1
  %conv1 = sext i8 %1 to i32
  %cmp2 = icmp eq i32 %conv1, -1
  br i1 %cmp2, label %if.then, label %if.end

if.then:                                          ; preds = %land.lhs.true
  %2 = load i8, ptr %dividend.addr, align 1
  store i8 %2, ptr %retval, align 1
  br label %return

if.end:                                           ; preds = %land.lhs.true, %entry
  %3 = load i8, ptr %dividend.addr, align 1
  %conv3 = sext i8 %3 to i32
  %4 = load i8, ptr %divisor.addr, align 1
  %conv4 = sext i8 %4 to i32
  %div = sdiv i32 %conv3, %conv4
  %conv5 = trunc i32 %div to i8
  store i8 %conv5, ptr %retval, align 1
  br label %return

return:                                           ; preds = %if.end, %if.then
  %5 = load i8, ptr %retval, align 1
  ret i8 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z13ByteRemainderaa(i8 noundef signext %dividend, i8 noundef signext %divisor) #0 {
entry:
  %retval = alloca i8, align 1
  %dividend.addr = alloca i8, align 1
  %divisor.addr = alloca i8, align 1
  store i8 %dividend, ptr %dividend.addr, align 1
  store i8 %divisor, ptr %divisor.addr, align 1
  %0 = load i8, ptr %divisor.addr, align 1
  %conv = sext i8 %0 to i32
  %cmp = icmp eq i32 %conv, -1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i8 0, ptr %retval, align 1
  br label %return

if.end:                                           ; preds = %entry
  %1 = load i8, ptr %dividend.addr, align 1
  %conv1 = sext i8 %1 to i32
  %2 = load i8, ptr %divisor.addr, align 1
  %conv2 = sext i8 %2 to i32
  %rem = srem i32 %conv1, %conv2
  %conv3 = trunc i32 %rem to i8
  store i8 %conv3, ptr %retval, align 1
  br label %return

return:                                           ; preds = %if.end, %if.then
  %3 = load i8, ptr %retval, align 1
  ret i8 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i16 @_Z12WordQuotientss(i16 noundef signext %dividend, i16 noundef signext %divisor) #0 {
entry:
  %retval = alloca i16, align 2
  %dividend.addr = alloca i16, align 2
  %divisor.addr = alloca i16, align 2
  store i16 %dividend, ptr %dividend.addr, align 2
  store i16 %divisor, ptr %divisor.addr, align 2
  %0 = load i16, ptr %dividend.addr, align 2
  %conv = sext i16 %0 to i32
  %cmp = icmp eq i32 %conv, -32768
  br i1 %cmp, label %land.lhs.true, label %if.end

land.lhs.true:                                    ; preds = %entry
  %1 = load i16, ptr %divisor.addr, align 2
  %conv1 = sext i16 %1 to i32
  %cmp2 = icmp eq i32 %conv1, -1
  br i1 %cmp2, label %if.then, label %if.end

if.then:                                          ; preds = %land.lhs.true
  %2 = load i16, ptr %dividend.addr, align 2
  store i16 %2, ptr %retval, align 2
  br label %return

if.end:                                           ; preds = %land.lhs.true, %entry
  %3 = load i16, ptr %dividend.addr, align 2
  %conv3 = sext i16 %3 to i32
  %4 = load i16, ptr %divisor.addr, align 2
  %conv4 = sext i16 %4 to i32
  %div = sdiv i32 %conv3, %conv4
  %conv5 = trunc i32 %div to i16
  store i16 %conv5, ptr %retval, align 2
  br label %return

return:                                           ; preds = %if.end, %if.then
  %5 = load i16, ptr %retval, align 2
  ret i16 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z13WideRemainderxx(i64 noundef %dividend, i64 noundef %divisor) #0 {
entry:
  %retval = alloca i64, align 8
  %dividend.addr = alloca i64, align 8
  %divisor.addr = alloca i64, align 8
  store i64 %dividend, ptr %dividend.addr, align 8
  store i64 %divisor, ptr %divisor.addr, align 8
  %0 = load i64, ptr %divisor.addr, align 8
  %cmp = icmp eq i64 %0, -1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i64 0, ptr %retval, align 8
  br label %return

if.end:                                           ; preds = %entry
  %1 = load i64, ptr %dividend.addr, align 8
  %2 = load i64, ptr %divisor.addr, align 8
  %rem = srem i64 %1, %2
  store i64 %rem, ptr %retval, align 8
  br label %return

return:                                           ; preds = %if.end, %if.then
  %3 = load i64, ptr %retval, align 8
  ret i64 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z12SizeQuotientll(i64 noundef %dividend, i64 noundef %divisor) #0 {
entry:
  %retval = alloca i64, align 8
  %dividend.addr = alloca i64, align 8
  %divisor.addr = alloca i64, align 8
  store i64 %dividend, ptr %dividend.addr, align 8
  store i64 %divisor, ptr %divisor.addr, align 8
  %0 = load i64, ptr %dividend.addr, align 8
  %cmp = icmp eq i64 %0, -9223372036854775808
  br i1 %cmp, label %land.lhs.true, label %if.end

land.lhs.true:                                    ; preds = %entry
  %1 = load i64, ptr %divisor.addr, align 8
  %cmp1 = icmp eq i64 %1, -1
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %land.lhs.true
  %2 = load i64, ptr %dividend.addr, align 8
  store i64 %2, ptr %retval, align 8
  br label %return

if.end:                                           ; preds = %land.lhs.true, %entry
  %3 = load i64, ptr %dividend.addr, align 8
  %4 = load i64, ptr %divisor.addr, align 8
  %div = sdiv i64 %3, %4
  store i64 %div, ptr %retval, align 8
  br label %return

return:                                           ; preds = %if.end, %if.then
  %5 = load i64, ptr %retval, align 8
  ret i64 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z20UnsignedByteQuotienthh(i8 noundef zeroext %dividend, i8 noundef zeroext %divisor) #0 {
entry:
  %dividend.addr = alloca i8, align 1
  %divisor.addr = alloca i8, align 1
  store i8 %dividend, ptr %dividend.addr, align 1
  store i8 %divisor, ptr %divisor.addr, align 1
  %0 = load i8, ptr %dividend.addr, align 1
  %conv = zext i8 %0 to i32
  %1 = load i8, ptr %divisor.addr, align 1
  %conv1 = zext i8 %1 to i32
  %div = sdiv i32 %conv, %conv1
  %conv2 = trunc i32 %div to i8
  ret i8 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z21UnsignedWordRemaindertt(i16 noundef zeroext %dividend, i16 noundef zeroext %divisor) #0 {
entry:
  %dividend.addr = alloca i16, align 2
  %divisor.addr = alloca i16, align 2
  store i16 %dividend, ptr %dividend.addr, align 2
  store i16 %divisor, ptr %divisor.addr, align 2
  %0 = load i16, ptr %dividend.addr, align 2
  %conv = zext i16 %0 to i32
  %1 = load i16, ptr %divisor.addr, align 2
  %conv1 = zext i16 %1 to i32
  %rem = srem i32 %conv, %conv1
  %conv2 = trunc i32 %rem to i16
  ret i16 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z18Unsigned32Quotientjj(i32 noundef %dividend, i32 noundef %divisor) #0 {
entry:
  %dividend.addr = alloca i32, align 4
  %divisor.addr = alloca i32, align 4
  store i32 %dividend, ptr %dividend.addr, align 4
  store i32 %divisor, ptr %divisor.addr, align 4
  %0 = load i32, ptr %dividend.addr, align 4
  %1 = load i32, ptr %divisor.addr, align 4
  %div = udiv i32 %0, %1
  ret i32 %div
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z21UnsignedWideRemainderyy(i64 noundef %dividend, i64 noundef %divisor) #0 {
entry:
  %dividend.addr = alloca i64, align 8
  %divisor.addr = alloca i64, align 8
  store i64 %dividend, ptr %dividend.addr, align 8
  store i64 %divisor, ptr %divisor.addr, align 8
  %0 = load i64, ptr %dividend.addr, align 8
  %1 = load i64, ptr %divisor.addr, align 8
  %rem = urem i64 %0, %1
  ret i64 %rem
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z20UnsignedSizeQuotientmm(i64 noundef %dividend, i64 noundef %divisor) #0 {
entry:
  %dividend.addr = alloca i64, align 8
  %divisor.addr = alloca i64, align 8
  store i64 %dividend, ptr %dividend.addr, align 8
  store i64 %divisor, ptr %divisor.addr, align 8
  %0 = load i64, ptr %dividend.addr, align 8
  %1 = load i64, ptr %divisor.addr, align 8
  %div = udiv i64 %0, %1
  ret i64 %div
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z23UnsignedMaximumQuotienty(i64 noundef %value) #0 {
entry:
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %div = udiv i64 %0, -1
  ret i64 %div
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z24UnsignedMaximumRemaindery(i64 noundef %value) #0 {
entry:
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %rem = urem i64 %0, -1
  ret i64 %rem
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z15MinimumQuotientv() #0 {
entry:
  ret i64 -9223372036854775808
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z16MinimumRemainderv() #0 {
entry:
  ret i64 0
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
