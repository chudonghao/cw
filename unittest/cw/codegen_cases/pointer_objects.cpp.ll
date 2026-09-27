; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names pointer_objects.cpp -o -
; ModuleID = 'pointer_objects.cpp'
source_filename = "pointer_objects.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7AddressRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4ReadPKi(ptr noundef %pointer) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i32, ptr %0, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5WritePii(ptr noundef %pointer, i32 noundef %value) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %pointer, ptr %pointer.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %1 = load ptr, ptr %pointer.addr, align 8
  store i32 %0, ptr %1, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z6TogglePb(ptr noundef %pointer) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i8, ptr %0, align 1
  %loadedv = icmp ne i8 %1, 0
  %lnot = xor i1 %loadedv, true
  %2 = load ptr, ptr %pointer.addr, align 8
  %storedv = zext i1 %lnot to i8
  store i8 %storedv, ptr %2, align 1
  %3 = load ptr, ptr %pointer.addr, align 8
  %4 = load i8, ptr %3, align 1
  %loadedv1 = icmp ne i8 %4, 0
  ret i1 %loadedv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z6DoublePdd(ptr noundef %pointer, double noundef %value) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %value.addr = alloca double, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  store double %0, ptr %1, align 8
  %2 = load ptr, ptr %pointer.addr, align 8
  %3 = load double, ptr %2, align 8
  ret double %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z6NestedPPiS_(ptr noundef %pointer, ptr noundef %other) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %other, ptr %other.addr, align 8
  %0 = load ptr, ptr %other.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  store ptr %0, ptr %1, align 8
  %2 = load ptr, ptr %pointer.addr, align 8
  %3 = load ptr, ptr %2, align 8
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5Localv() #0 {
entry:
  %value = alloca i32, align 4
  %pointer = alloca ptr, align 8
  store i32 7, ptr %value, align 4
  store ptr %value, ptr %pointer, align 8
  %0 = load ptr, ptr %pointer, align 8
  store i32 11, ptr %0, align 4
  %1 = load ptr, ptr %pointer, align 8
  %call = call noundef i32 @_Z4ReadPKi(ptr noundef %1)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z8ReceiverPi(ptr noundef %pointer) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %call = call noundef ptr @_Z7AddressRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret ptr %call
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
