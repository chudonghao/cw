; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names boolean_objects.cpp -o -
; ModuleID = 'boolean_objects.cpp'
source_filename = "boolean_objects.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z4Flipb(i1 noundef zeroext %value) #0 {
entry:
  %value.addr = alloca i8, align 1
  %storedv = zext i1 %value to i8
  store i8 %storedv, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %lnot = xor i1 %loadedv, true
  %storedv1 = zext i1 %lnot to i8
  store i8 %storedv1, ptr %value.addr, align 1
  %1 = load i8, ptr %value.addr, align 1
  %loadedv2 = icmp ne i8 %1, 0
  ret i1 %loadedv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 1 dereferenceable(1) ptr @_Z5ReferRb(ptr noundef nonnull align 1 dereferenceable(1) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z14BooleanObjectsv() #0 {
entry:
  %original = alloca i8, align 1
  %copied = alloca i8, align 1
  %bound = alloca ptr, align 8
  store i8 1, ptr %original, align 1
  %0 = load i8, ptr %original, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef zeroext i1 @_Z4Flipb(i1 noundef zeroext %loadedv)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %copied, align 1
  %call1 = call noundef nonnull align 1 dereferenceable(1) ptr @_Z5ReferRb(ptr noundef nonnull align 1 dereferenceable(1) %original)
  store ptr %call1, ptr %bound, align 8
  %1 = load ptr, ptr %bound, align 8, !nonnull !5
  store i8 0, ptr %1, align 1
  %2 = load i8, ptr %copied, align 1
  %loadedv2 = icmp ne i8 %2, 0
  ret i1 %loadedv2
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
