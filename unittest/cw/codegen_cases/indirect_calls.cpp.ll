; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names indirect_calls.cpp -o -
; ModuleID = 'indirect_calls.cpp'
source_filename = "indirect_calls.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef signext i8 @_Z6SignedPFaaEa(ptr noundef %callback, i8 noundef signext %value) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i8, align 1
  store ptr %callback, ptr %callback.addr, align 8
  store i8 %value, ptr %value.addr, align 1
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i8, ptr %value.addr, align 1
  %call = call noundef signext i8 %0(i8 noundef signext %1)
  ret i8 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z8UnsignedPFttEt(ptr noundef %callback, i16 noundef zeroext %value) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i16, align 2
  store ptr %callback, ptr %callback.addr, align 8
  store i16 %value, ptr %value.addr, align 2
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i16, ptr %value.addr, align 2
  %call = call noundef zeroext i16 %0(i16 noundef zeroext %1)
  ret i16 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z7BooleanPFbbEb(ptr noundef %callback, i1 noundef zeroext %value) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i8, align 1
  store ptr %callback, ptr %callback.addr, align 8
  %storedv = zext i1 %value to i8
  store i8 %storedv, ptr %value.addr, align 1
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i8, ptr %value.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  %call = call noundef zeroext i1 %0(i1 noundef zeroext %loadedv)
  ret i1 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef double @_Z8FloatingPFdfEi(ptr noundef %callback, i32 noundef %value) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %callback, ptr %callback.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i32, ptr %value.addr, align 4
  %conv = sitofp i32 %1 to float
  %call = call noundef double %0(float noundef %conv)
  ret double %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z9ReferencePFRiS_ES_(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z13ReadReferencePFRKiS0_ES0_(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load i32, ptr %call, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z13MoveReferencePFOiS_ES_(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4VoidPFvPiES_(ptr noundef %callback, ptr noundef %pointer) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  call void %0(ptr noundef %1)
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z7ChainedPFPFiiEvEi(ptr noundef %factory, i32 noundef %value) #0 {
entry:
  %factory.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %factory, ptr %factory.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %factory.addr, align 8
  %call = call noundef ptr %0()
  %1 = load i32, ptr %value.addr, align 4
  %call1 = call noundef i32 %call(i32 noundef %1)
  ret i32 %call1
}

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
