; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names conditional_value.cpp -o -
; ModuleID = 'conditional_value.cpp'
source_filename = "conditional_value.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z16ConditionalValuebbii(i1 noundef zeroext %flag, i1 noundef zeroext %other, i32 noundef %left, i32 noundef %right) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %other.addr = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %other to i8
  store i8 %storedv1, ptr %other.addr, align 1
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false4

cond.true:                                        ; preds = %entry
  %1 = load i8, ptr %other.addr, align 1
  %loadedv2 = icmp ne i8 %1, 0
  br i1 %loadedv2, label %cond.true3, label %cond.false

cond.true3:                                       ; preds = %cond.true
  %2 = load i32, ptr %left.addr, align 4
  br label %cond.end

cond.false:                                       ; preds = %cond.true
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true3
  %cond = phi i32 [ %2, %cond.true3 ], [ 7, %cond.false ]
  br label %cond.end10

cond.false4:                                      ; preds = %entry
  %3 = load i8, ptr %other.addr, align 1
  %loadedv5 = icmp ne i8 %3, 0
  br i1 %loadedv5, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %cond.false4
  br label %cond.end8

cond.false7:                                      ; preds = %cond.false4
  %4 = load i32, ptr %right.addr, align 4
  br label %cond.end8

cond.end8:                                        ; preds = %cond.false7, %cond.true6
  %cond9 = phi i32 [ 11, %cond.true6 ], [ %4, %cond.false7 ]
  br label %cond.end10

cond.end10:                                       ; preds = %cond.end8, %cond.end
  %cond11 = phi i32 [ %cond, %cond.end ], [ %cond9, %cond.end8 ]
  ret i32 %cond11
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
