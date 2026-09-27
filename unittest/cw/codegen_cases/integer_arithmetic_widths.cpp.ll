; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names integer_arithmetic_widths.cpp -o -
; ModuleID = 'integer_arithmetic_widths.cpp'
source_filename = "integer_arithmetic_widths.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z20SignedByteArithmeticaa(i8 noundef signext %left, i8 noundef signext %right) #0 {
entry:
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  store i8 %left, ptr %left.addr, align 1
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %conv = sext i8 %0 to i32
  %1 = load i8, ptr %right.addr, align 1
  %conv1 = sext i8 %1 to i32
  %sub = sub nsw i32 0, %conv1
  %add = add nsw i32 %conv, %sub
  %2 = load i8, ptr %left.addr, align 1
  %conv2 = sext i8 %2 to i32
  %3 = load i8, ptr %right.addr, align 1
  %conv3 = sext i8 %3 to i32
  %sub4 = sub nsw i32 %conv2, %conv3
  %mul = mul nsw i32 %add, %sub4
  %conv5 = trunc i32 %mul to i8
  ret i8 %conv5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z22UnsignedWordArithmetictt(i16 noundef zeroext %left, i16 noundef zeroext %right) #0 {
entry:
  %left.addr = alloca i16, align 2
  %right.addr = alloca i16, align 2
  %sum = alloca i16, align 2
  %difference = alloca i16, align 2
  store i16 %left, ptr %left.addr, align 2
  store i16 %right, ptr %right.addr, align 2
  %0 = load i16, ptr %left.addr, align 2
  %conv = zext i16 %0 to i32
  %1 = load i16, ptr %right.addr, align 2
  %conv1 = zext i16 %1 to i32
  %add = add nsw i32 %conv, %conv1
  %conv2 = trunc i32 %add to i16
  store i16 %conv2, ptr %sum, align 2
  %2 = load i16, ptr %left.addr, align 2
  %conv3 = zext i16 %2 to i32
  %3 = load i16, ptr %right.addr, align 2
  %conv4 = zext i16 %3 to i32
  %sub = sub nsw i32 %conv3, %conv4
  %conv5 = trunc i32 %sub to i16
  store i16 %conv5, ptr %difference, align 2
  %4 = load i16, ptr %sum, align 2
  %conv6 = zext i16 %4 to i32
  %5 = load i16, ptr %difference, align 2
  %conv7 = zext i16 %5 to i32
  %mul = mul i32 %conv6, %conv7
  %conv8 = trunc i32 %mul to i16
  ret i16 %conv8
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z22UnsignedWideArithmeticyy(i64 noundef %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %add = add i64 %0, %1
  %2 = load i64, ptr %left.addr, align 8
  %3 = load i64, ptr %right.addr, align 8
  %sub = sub i64 %2, %3
  %mul = mul i64 %add, %sub
  ret i64 %mul
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z16SignedWideNegatex(i64 noundef %value) #0 {
entry:
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %sub = sub i64 0, %0
  ret i64 %sub
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z15MixedArithmeticat(i8 noundef signext %left, i16 noundef zeroext %right) #0 {
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
  %add = add nsw i32 %conv1, %conv2
  %conv3 = trunc i32 %add to i16
  %conv4 = zext i16 %conv3 to i32
  ret i32 %conv4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z14SizeArithmeticlm(i64 noundef %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %add = add i64 %0, %1
  ret i64 %add
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
