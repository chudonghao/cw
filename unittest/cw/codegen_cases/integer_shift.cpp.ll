; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names integer_shift.cpp -o -
; ModuleID = 'integer_shift.cpp'
source_filename = "integer_shift.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z10SignedByteay(i8 noundef signext %left, i64 noundef %count) #0 {
entry:
  %left.addr = alloca i8, align 1
  %count.addr = alloca i64, align 8
  store i8 %left, ptr %left.addr, align 1
  store i64 %count, ptr %count.addr, align 8
  %0 = load i8, ptr %left.addr, align 1
  %conv = sext i8 %0 to i32
  %1 = load i64, ptr %count.addr, align 8
  %and = and i64 %1, 7
  %sh_prom = trunc i64 %and to i32
  %shl = shl i32 %conv, %sh_prom
  %conv1 = trunc i32 %shl to i8
  ret i8 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z12UnsignedBytehx(i8 noundef zeroext %left, i64 noundef %count) #0 {
entry:
  %left.addr = alloca i8, align 1
  %count.addr = alloca i64, align 8
  store i8 %left, ptr %left.addr, align 1
  store i64 %count, ptr %count.addr, align 8
  %0 = load i8, ptr %left.addr, align 1
  %conv = zext i8 %0 to i32
  %1 = load i64, ptr %count.addr, align 8
  %and = and i64 %1, 7
  %sh_prom = trunc i64 %and to i32
  %shr = ashr i32 %conv, %sh_prom
  %conv1 = trunc i32 %shr to i8
  ret i8 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z15SignedByteRightax(i8 noundef signext %left, i64 noundef %count) #0 {
entry:
  %left.addr = alloca i8, align 1
  %count.addr = alloca i64, align 8
  store i8 %left, ptr %left.addr, align 1
  store i64 %count, ptr %count.addr, align 8
  %0 = load i8, ptr %left.addr, align 1
  %conv = sext i8 %0 to i32
  %1 = load i64, ptr %count.addr, align 8
  %and = and i64 %1, 7
  %sh_prom = trunc i64 %and to i32
  %shr = ashr i32 %conv, %sh_prom
  %conv1 = trunc i32 %shr to i8
  ret i8 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i16 @_Z10SignedWordsh(i16 noundef signext %left, i8 noundef zeroext %count) #0 {
entry:
  %left.addr = alloca i16, align 2
  %count.addr = alloca i8, align 1
  store i16 %left, ptr %left.addr, align 2
  store i8 %count, ptr %count.addr, align 1
  %0 = load i16, ptr %left.addr, align 2
  %conv = sext i16 %0 to i32
  %1 = load i8, ptr %count.addr, align 1
  %conv1 = zext i8 %1 to i32
  %and = and i32 %conv1, 15
  %shl = shl i32 %conv, %and
  %conv2 = trunc i32 %shl to i16
  ret i16 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z12UnsignedWordta(i16 noundef zeroext %left, i8 noundef signext %count) #0 {
entry:
  %left.addr = alloca i16, align 2
  %count.addr = alloca i8, align 1
  store i16 %left, ptr %left.addr, align 2
  store i8 %count, ptr %count.addr, align 1
  %0 = load i16, ptr %left.addr, align 2
  %conv = zext i16 %0 to i32
  %1 = load i8, ptr %count.addr, align 1
  %conv1 = sext i8 %1 to i32
  %and = and i32 %conv1, 15
  %shr = ashr i32 %conv, %and
  %conv2 = trunc i32 %shr to i16
  ret i16 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8Signed32ix(i32 noundef %left, i64 noundef %count) #0 {
entry:
  %left.addr = alloca i32, align 4
  %count.addr = alloca i64, align 8
  store i32 %left, ptr %left.addr, align 4
  store i64 %count, ptr %count.addr, align 8
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i64, ptr %count.addr, align 8
  %and = and i64 %1, 31
  %sh_prom = trunc i64 %and to i32
  %shl = shl i32 %0, %sh_prom
  ret i32 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z13Signed32Rightiy(i32 noundef %left, i64 noundef %count) #0 {
entry:
  %left.addr = alloca i32, align 4
  %count.addr = alloca i64, align 8
  store i32 %left, ptr %left.addr, align 4
  store i64 %count, ptr %count.addr, align 8
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i64, ptr %count.addr, align 8
  %and = and i64 %1, 31
  %sh_prom = trunc i64 %and to i32
  %shr = ashr i32 %0, %sh_prom
  ret i32 %shr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z10Unsigned32js(i32 noundef %left, i16 noundef signext %count) #0 {
entry:
  %left.addr = alloca i32, align 4
  %count.addr = alloca i16, align 2
  store i32 %left, ptr %left.addr, align 4
  store i16 %count, ptr %count.addr, align 2
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i16, ptr %count.addr, align 2
  %conv = sext i16 %1 to i32
  %and = and i32 %conv, 31
  %shl = shl i32 %0, %and
  ret i32 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z8Signed64xa(i64 noundef %left, i8 noundef signext %count) #0 {
entry:
  %left.addr = alloca i64, align 8
  %count.addr = alloca i8, align 1
  store i64 %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i8, ptr %count.addr, align 1
  %conv = sext i8 %1 to i32
  %and = and i32 %conv, 63
  %sh_prom = zext i32 %and to i64
  %shr = ashr i64 %0, %sh_prom
  ret i64 %shr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z10Unsigned64yj(i64 noundef %left, i32 noundef %count) #0 {
entry:
  %left.addr = alloca i64, align 8
  %count.addr = alloca i32, align 4
  store i64 %left, ptr %left.addr, align 8
  store i32 %count, ptr %count.addr, align 4
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i32, ptr %count.addr, align 4
  %and = and i32 %1, 63
  %sh_prom = zext i32 %and to i64
  %shl = shl i64 %0, %sh_prom
  ret i64 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z4Sizeli(i64 noundef %left, i32 noundef %count) #0 {
entry:
  %left.addr = alloca i64, align 8
  %count.addr = alloca i32, align 4
  store i64 %left, ptr %left.addr, align 8
  store i32 %count, ptr %count.addr, align 4
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i32, ptr %count.addr, align 4
  %and = and i32 %1, 63
  %sh_prom = zext i32 %and to i64
  %shr = ashr i64 %0, %sh_prom
  ret i64 %shr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z12UnsignedSizemh(i64 noundef %left, i8 noundef zeroext %count) #0 {
entry:
  %left.addr = alloca i64, align 8
  %count.addr = alloca i8, align 1
  store i64 %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i8, ptr %count.addr, align 1
  %conv = zext i8 %1 to i32
  %and = and i32 %conv, 63
  %sh_prom = zext i32 %and to i64
  %shl = shl i64 %0, %sh_prom
  ret i64 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z11FixedBySizehm(i8 noundef zeroext %left, i64 noundef %count) #0 {
entry:
  %left.addr = alloca i8, align 1
  %count.addr = alloca i64, align 8
  store i8 %left, ptr %left.addr, align 1
  store i64 %count, ptr %count.addr, align 8
  %0 = load i8, ptr %left.addr, align 1
  %conv = zext i8 %0 to i32
  %1 = load i64, ptr %count.addr, align 8
  %and = and i64 %1, 7
  %sh_prom = trunc i64 %and to i32
  %shl = shl i32 %conv, %sh_prom
  %conv1 = trunc i32 %shl to i8
  ret i8 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z19ShiftBeforeWideningh(i8 noundef zeroext %left) #0 {
entry:
  %left.addr = alloca i8, align 1
  store i8 %left, ptr %left.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %conv = zext i8 %0 to i32
  %shl = shl i32 %conv, 1
  %conv1 = trunc i32 %shl to i8
  %conv2 = zext i8 %conv1 to i32
  ret i32 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9Literal32y(i64 noundef %count) #0 {
entry:
  %count.addr = alloca i64, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  %and = and i64 %0, 31
  %sh_prom = trunc i64 %and to i32
  %shl = shl i32 1, %sh_prom
  ret i32 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z15FoldedWideCountv() #0 {
entry:
  ret i32 1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z19FoldedNegativeCountv() #0 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z18FoldedNegativeLeftv() #0 {
entry:
  ret i32 -6
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z13FoldedSignBitv() #0 {
entry:
  ret i32 -2147483648
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z14FoldedLostBitsv() #0 {
entry:
  ret i32 0
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
