; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti import_indirect.cpp -o -
; ModuleID = 'import_indirect.cpp'
source_filename = "import_indirect.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8DispatchRK4Base(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %first = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %0, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 0
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef i32 %1(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store i32 %call, ptr %first, align 4
  %2 = load i32, ptr %first, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %vtable1 = load ptr, ptr %3, align 8
  %vfn2 = getelementptr inbounds ptr, ptr %vtable1, i64 1
  %4 = load ptr, ptr %vfn2, align 8
  %call3 = call noundef i32 %4(ptr noundef nonnull align 8 dereferenceable(8) %3)
  %add = add nsw i32 %2, %call3
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z4Slotv() #1 {
entry:
  %retval = alloca { i64, i64 }, align 8
  store { i64, i64 } { i64 0, i64 1 }, ptr %retval, align 8
  %0 = load [2 x i64], ptr %retval, align 8
  ret [2 x i64] %0
}

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 8}
