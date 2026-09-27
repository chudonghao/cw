; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names array_loop.cpp -o -
; ModuleID = 'array_loop.cpp'
source_filename = "array_loop.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z3SumRA2_Kimmm(ptr noundef nonnull align 4 dereferenceable(8) %values, i64 noundef %begin, i64 noundef %end, i64 noundef %step) #0 {
entry:
  %values.addr = alloca ptr, align 8
  %begin.addr = alloca i64, align 8
  %end.addr = alloca i64, align 8
  %step.addr = alloca i64, align 8
  %total = alloca i32, align 4
  %index = alloca i64, align 8
  store ptr %values, ptr %values.addr, align 8
  store i64 %begin, ptr %begin.addr, align 8
  store i64 %end, ptr %end.addr, align 8
  store i64 %step, ptr %step.addr, align 8
  store i32 0, ptr %total, align 4
  %0 = load i64, ptr %begin.addr, align 8
  store i64 %0, ptr %index, align 8
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %1 = load i64, ptr %index, align 8
  %2 = load i64, ptr %end.addr, align 8
  %cmp = icmp ult i64 %1, %2
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %3 = load i32, ptr %total, align 4
  %4 = load ptr, ptr %values.addr, align 8, !nonnull !5, !align !6
  %5 = load i64, ptr %index, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %4, i64 0, i64 %5
  %6 = load i32, ptr %arrayidx, align 4
  %add = add nsw i32 %3, %6
  store i32 %add, ptr %total, align 4
  %7 = load i64, ptr %index, align 8
  %8 = load i64, ptr %step.addr, align 8
  %add1 = add i64 %7, %8
  store i64 %add1, ptr %index, align 8
  br label %while.cond, !llvm.loop !7

while.end:                                        ; preds = %while.cond
  %9 = load i32, ptr %total, align 4
  ret i32 %9
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
!7 = distinct !{!7, !8}
!8 = !{!"llvm.loop.mustprogress"}
