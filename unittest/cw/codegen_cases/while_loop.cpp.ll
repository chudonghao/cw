; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names while_loop.cpp -o -
; ModuleID = 'while_loop.cpp'
source_filename = "while_loop.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z4TickRb(ptr noundef nonnull align 1 dereferenceable(1) %flag) #0 {
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
  %3 = load ptr, ptr %flag.addr, align 8, !nonnull !5
  %4 = load i8, ptr %3, align 1
  %loadedv1 = icmp ne i8 %4, 0
  ret i1 %loadedv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9WhileLoopRbbb(ptr noundef nonnull align 1 dereferenceable(1) %flag, i1 noundef zeroext %skip, i1 noundef zeroext %leave) #0 {
entry:
  %flag.addr = alloca ptr, align 8
  %skip.addr = alloca i8, align 1
  %leave.addr = alloca i8, align 1
  %result = alloca i32, align 4
  store ptr %flag, ptr %flag.addr, align 8
  %storedv = zext i1 %skip to i8
  store i8 %storedv, ptr %skip.addr, align 1
  %storedv1 = zext i1 %leave to i8
  store i8 %storedv1, ptr %leave.addr, align 1
  store i32 0, ptr %result, align 4
  br label %while.cond

while.cond:                                       ; preds = %if.end4, %if.then3, %entry
  %0 = load ptr, ptr %flag.addr, align 8, !nonnull !5
  %call = call noundef zeroext i1 @_Z4TickRb(ptr noundef nonnull align 1 dereferenceable(1) %0)
  br i1 %call, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %1 = load i8, ptr %leave.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  br i1 %loadedv, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  br label %while.end

if.end:                                           ; preds = %while.body
  %2 = load i8, ptr %skip.addr, align 1
  %loadedv2 = icmp ne i8 %2, 0
  br i1 %loadedv2, label %if.then3, label %if.end4

if.then3:                                         ; preds = %if.end
  store i8 0, ptr %skip.addr, align 1
  br label %while.cond, !llvm.loop !6

if.end4:                                          ; preds = %if.end
  store i32 9, ptr %result, align 4
  br label %while.cond, !llvm.loop !6

while.end:                                        ; preds = %if.then, %while.cond
  %3 = load i32, ptr %result, align 4
  ret i32 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11NestedLoopsbbbb(i1 noundef zeroext %outer, i1 noundef zeroext %inner, i1 noundef zeroext %stop, i1 noundef zeroext %finish) #0 {
entry:
  %retval = alloca i32, align 4
  %outer.addr = alloca i8, align 1
  %inner.addr = alloca i8, align 1
  %stop.addr = alloca i8, align 1
  %finish.addr = alloca i8, align 1
  %storedv = zext i1 %outer to i8
  store i8 %storedv, ptr %outer.addr, align 1
  %storedv1 = zext i1 %inner to i8
  store i8 %storedv1, ptr %inner.addr, align 1
  %storedv2 = zext i1 %stop to i8
  store i8 %storedv2, ptr %stop.addr, align 1
  %storedv3 = zext i1 %finish to i8
  store i8 %storedv3, ptr %finish.addr, align 1
  br label %while.cond

while.cond:                                       ; preds = %if.end13, %entry
  %0 = load i8, ptr %outer.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %while.body, label %while.end14

while.body:                                       ; preds = %while.cond
  br label %while.cond4

while.cond4:                                      ; preds = %if.end, %while.body
  %1 = load i8, ptr %inner.addr, align 1
  %loadedv5 = icmp ne i8 %1, 0
  br i1 %loadedv5, label %while.body6, label %while.end

while.body6:                                      ; preds = %while.cond4
  %2 = load i8, ptr %stop.addr, align 1
  %loadedv7 = icmp ne i8 %2, 0
  br i1 %loadedv7, label %if.then, label %if.end

if.then:                                          ; preds = %while.body6
  br label %while.end

if.end:                                           ; preds = %while.body6
  store i8 0, ptr %inner.addr, align 1
  br label %while.cond4, !llvm.loop !8

while.end:                                        ; preds = %if.then, %while.cond4
  %3 = load i8, ptr %finish.addr, align 1
  %loadedv8 = icmp ne i8 %3, 0
  br i1 %loadedv8, label %if.then9, label %if.end10

if.then9:                                         ; preds = %while.end
  store i32 7, ptr %retval, align 4
  br label %return

if.end10:                                         ; preds = %while.end
  %4 = load i8, ptr %stop.addr, align 1
  %loadedv11 = icmp ne i8 %4, 0
  br i1 %loadedv11, label %if.then12, label %if.end13

if.then12:                                        ; preds = %if.end10
  br label %while.end14

if.end13:                                         ; preds = %if.end10
  store i8 0, ptr %outer.addr, align 1
  br label %while.cond, !llvm.loop !9

while.end14:                                      ; preds = %if.then12, %while.cond
  store i32 9, ptr %retval, align 4
  br label %return

return:                                           ; preds = %while.end14, %if.then9
  %5 = load i32, ptr %retval, align 4
  ret i32 %5
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
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
