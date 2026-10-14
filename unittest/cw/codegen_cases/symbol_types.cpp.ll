; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti symbol_types.cpp -o -
; ModuleID = 'symbol_types.cpp'
source_filename = "symbol_types.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@ScalarSize = global ptr @_ZN3api6ScalarEl, align 8
@ScalarFixed = global ptr @_ZN3api6ScalarEx, align 8
@Copy = global ptr @_ZN3api9ReferenceERKi, align 8
@Mut = global ptr @_ZN3api9ReferenceERi, align 8
@Move = global ptr @_ZN3api9ReferenceEOi, align 8
@ConstPointer = global ptr @_ZN3api9QualifiedEPKPi, align 8
@ConstPointee = global ptr @_ZN3api9QualifiedEPPKi, align 8
@Array = global ptr @_ZN3api5ArrayERA4_Ki, align 8
@Direct = global ptr @_ZN3api8CallbackEPFiiE, align 8
@Virtual = global ptr @_ZN3api8CallbackEMNS_5OwnerEKFivE, align 8
@NestedMain = global ptr @_ZN3api4mainEi, align 8
@Unicode = global ptr @"_ZN3api6\E8\AF\BB\E5\8F\96Ei", align 8

declare noundef i32 @_ZN3api6ScalarEl(i64 noundef) #0

declare noundef i32 @_ZN3api6ScalarEx(i64 noundef) #0

declare noundef i32 @_ZN3api9ReferenceERKi(ptr noundef nonnull align 4 dereferenceable(4)) #0

declare noundef i32 @_ZN3api9ReferenceERi(ptr noundef nonnull align 4 dereferenceable(4)) #0

declare noundef i32 @_ZN3api9ReferenceEOi(ptr noundef nonnull align 4 dereferenceable(4)) #0

declare noundef i32 @_ZN3api9QualifiedEPKPi(ptr noundef) #0

declare noundef i32 @_ZN3api9QualifiedEPPKi(ptr noundef) #0

declare noundef i32 @_ZN3api5ArrayERA4_Ki(ptr noundef nonnull align 4 dereferenceable(16)) #0

declare noundef i32 @_ZN3api8CallbackEPFiiE(ptr noundef) #0

declare noundef i32 @_ZN3api8CallbackEMNS_5OwnerEKFivE([2 x i64]) #0

declare noundef i32 @_ZN3api4mainEi(i32 noundef) #0

declare noundef i32 @"_ZN3api6\E8\AF\BB\E5\8F\96Ei"(i32 noundef) #0

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7DestroyPN3api5OwnerE(ptr noundef %value) #1 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef ptr @_ZN3api5OwnerD1Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %0) #3
  ret void
}

; Function Attrs: nounwind
declare noundef ptr @_ZN3api5OwnerD1Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8)) unnamed_addr #2

attributes #0 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
