; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names integer_bitwise.cpp -o -
; ModuleID = 'integer_bitwise.cpp'
source_filename = "integer_bitwise.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z12UnsignedBytehh(i8 noundef zeroext %left, i8 noundef zeroext %right) #0 {
entry:
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %inverted = alloca i8, align 1
  %both = alloca i8, align 1
  %different = alloca i8, align 1
  store i8 %left, ptr %left.addr, align 1
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %conv = zext i8 %0 to i32
  %not = xor i32 %conv, -1
  %conv1 = trunc i32 %not to i8
  store i8 %conv1, ptr %inverted, align 1
  %1 = load i8, ptr %inverted, align 1
  %conv2 = zext i8 %1 to i32
  %2 = load i8, ptr %right.addr, align 1
  %conv3 = zext i8 %2 to i32
  %and = and i32 %conv2, %conv3
  %conv4 = trunc i32 %and to i8
  store i8 %conv4, ptr %both, align 1
  %3 = load i8, ptr %left.addr, align 1
  %conv5 = zext i8 %3 to i32
  %4 = load i8, ptr %right.addr, align 1
  %conv6 = zext i8 %4 to i32
  %xor = xor i32 %conv5, %conv6
  %conv7 = trunc i32 %xor to i8
  store i8 %conv7, ptr %different, align 1
  %5 = load i8, ptr %both, align 1
  %conv8 = zext i8 %5 to i32
  %6 = load i8, ptr %different, align 1
  %conv9 = zext i8 %6 to i32
  %or = or i32 %conv8, %conv9
  %conv10 = trunc i32 %or to i8
  ret i8 %conv10
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z10SignedByteaa(i8 noundef signext %left, i8 noundef signext %right) #0 {
entry:
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %inverted = alloca i8, align 1
  %both = alloca i8, align 1
  %different = alloca i8, align 1
  store i8 %left, ptr %left.addr, align 1
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %conv = sext i8 %0 to i32
  %not = xor i32 %conv, -1
  %conv1 = trunc i32 %not to i8
  store i8 %conv1, ptr %inverted, align 1
  %1 = load i8, ptr %inverted, align 1
  %conv2 = sext i8 %1 to i32
  %2 = load i8, ptr %right.addr, align 1
  %conv3 = sext i8 %2 to i32
  %and = and i32 %conv2, %conv3
  %conv4 = trunc i32 %and to i8
  store i8 %conv4, ptr %both, align 1
  %3 = load i8, ptr %left.addr, align 1
  %conv5 = sext i8 %3 to i32
  %4 = load i8, ptr %right.addr, align 1
  %conv6 = sext i8 %4 to i32
  %xor = xor i32 %conv5, %conv6
  %conv7 = trunc i32 %xor to i8
  store i8 %conv7, ptr %different, align 1
  %5 = load i8, ptr %both, align 1
  %conv8 = sext i8 %5 to i32
  %6 = load i8, ptr %different, align 1
  %conv9 = sext i8 %6 to i32
  %or = or i32 %conv8, %conv9
  %conv10 = trunc i32 %or to i8
  ret i8 %conv10
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z4Wordtt(i16 noundef zeroext %left, i16 noundef zeroext %right) #0 {
entry:
  %left.addr = alloca i16, align 2
  %right.addr = alloca i16, align 2
  %inverted = alloca i16, align 2
  %both = alloca i16, align 2
  %different = alloca i16, align 2
  store i16 %left, ptr %left.addr, align 2
  store i16 %right, ptr %right.addr, align 2
  %0 = load i16, ptr %left.addr, align 2
  %conv = zext i16 %0 to i32
  %not = xor i32 %conv, -1
  %conv1 = trunc i32 %not to i16
  store i16 %conv1, ptr %inverted, align 2
  %1 = load i16, ptr %inverted, align 2
  %conv2 = zext i16 %1 to i32
  %2 = load i16, ptr %right.addr, align 2
  %conv3 = zext i16 %2 to i32
  %and = and i32 %conv2, %conv3
  %conv4 = trunc i32 %and to i16
  store i16 %conv4, ptr %both, align 2
  %3 = load i16, ptr %left.addr, align 2
  %conv5 = zext i16 %3 to i32
  %4 = load i16, ptr %right.addr, align 2
  %conv6 = zext i16 %4 to i32
  %xor = xor i32 %conv5, %conv6
  %conv7 = trunc i32 %xor to i16
  store i16 %conv7, ptr %different, align 2
  %5 = load i16, ptr %both, align 2
  %conv8 = zext i16 %5 to i32
  %6 = load i16, ptr %different, align 2
  %conv9 = zext i16 %6 to i32
  %or = or i32 %conv8, %conv9
  %conv10 = trunc i32 %or to i16
  ret i16 %conv10
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z10SignedWordii(i32 noundef %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %not = xor i32 %0, -1
  %1 = load i32, ptr %right.addr, align 4
  %and = and i32 %not, %1
  %2 = load i32, ptr %left.addr, align 4
  %3 = load i32, ptr %right.addr, align 4
  %xor = xor i32 %2, %3
  %or = or i32 %and, %xor
  ret i32 %or
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z4Wideyy(i64 noundef %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %not = xor i64 %0, -1
  %1 = load i64, ptr %right.addr, align 8
  %and = and i64 %not, %1
  %2 = load i64, ptr %left.addr, align 8
  %3 = load i64, ptr %right.addr, align 8
  %xor = xor i64 %2, %3
  %or = or i64 %and, %xor
  ret i64 %or
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z5Mixedat(i8 noundef signext %left, i16 noundef zeroext %right) #0 {
entry:
  %left.addr = alloca i8, align 1
  %right.addr = alloca i16, align 2
  store i8 %left, ptr %left.addr, align 1
  store i16 %right, ptr %right.addr, align 2
  %0 = load i8, ptr %left.addr, align 1
  %conv = sext i8 %0 to i16
  %conv1 = zext i16 %conv to i32
  %1 = load i16, ptr %right.addr, align 2
  %conv2 = zext i16 %1 to i32
  %and = and i32 %conv1, %conv2
  %conv3 = trunc i32 %and to i16
  ret i16 %conv3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z4Sizelm(i64 noundef %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %not = xor i64 %0, -1
  %1 = load i64, ptr %right.addr, align 8
  %and = and i64 %not, %1
  ret i64 %and
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z20InvertBeforeWideningh(i8 noundef zeroext %value) #0 {
entry:
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %conv = zext i8 %0 to i32
  %not = xor i32 %conv, -1
  %conv1 = trunc i32 %not to i8
  %conv2 = zext i8 %conv1 to i32
  %and = and i32 %conv2, 256
  ret i32 %and
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z12FoldedSignedv() #0 {
entry:
  ret i64 -2147483649
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z14FoldedUnsignedv() #0 {
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
