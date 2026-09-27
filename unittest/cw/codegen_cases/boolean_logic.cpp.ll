; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names boolean_logic.cpp -o -
; ModuleID = 'boolean_logic.cpp'
source_filename = "boolean_logic.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z5TouchRb(ptr noundef nonnull align 1 dereferenceable(1) %flag) #0 {
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
define noundef zeroext i1 @_Z12BooleanLogicbbbRb(i1 noundef zeroext %a, i1 noundef zeroext %b, i1 noundef zeroext %c, ptr noundef nonnull align 1 dereferenceable(1) %flag) #0 {
entry:
  %a.addr = alloca i8, align 1
  %b.addr = alloca i8, align 1
  %c.addr = alloca i8, align 1
  %flag.addr = alloca ptr, align 8
  %storedv = zext i1 %a to i8
  store i8 %storedv, ptr %a.addr, align 1
  %storedv1 = zext i1 %b to i8
  store i8 %storedv1, ptr %b.addr, align 1
  %storedv2 = zext i1 %c to i8
  store i8 %storedv2, ptr %c.addr, align 1
  store ptr %flag, ptr %flag.addr, align 8
  %0 = load i8, ptr %a.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %land.lhs.true, label %land.end

land.lhs.true:                                    ; preds = %entry
  %1 = load i8, ptr %b.addr, align 1
  %loadedv3 = icmp ne i8 %1, 0
  br i1 %loadedv3, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %land.lhs.true
  %2 = load i8, ptr %c.addr, align 1
  %loadedv4 = icmp ne i8 %2, 0
  br i1 %loadedv4, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %land.rhs
  %3 = load ptr, ptr %flag.addr, align 8, !nonnull !5
  %call = call noundef zeroext i1 @_Z5TouchRb(ptr noundef nonnull align 1 dereferenceable(1) %3)
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %land.rhs
  %4 = phi i1 [ true, %land.rhs ], [ %call, %lor.rhs ]
  br label %land.end

land.end:                                         ; preds = %lor.end, %land.lhs.true, %entry
  %5 = phi i1 [ false, %land.lhs.true ], [ false, %entry ], [ %4, %lor.end ]
  ret i1 %5
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
