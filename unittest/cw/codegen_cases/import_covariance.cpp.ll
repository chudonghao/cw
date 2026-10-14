; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti import_covariance.cpp -o -
; ModuleID = 'import_covariance.cpp'
source_filename = "import_covariance.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@_ZTV5Local = linkonce_odr unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr @_ZTch0_h8_NK13SpecialSource7PointerEv, ptr @_ZTch0_h8_NK13SpecialSource9ReferenceEv, ptr @_ZNK13SpecialSource7PointerEv, ptr @_ZNK13SpecialSource9ReferenceEv] }, align 8
@_ZTV7Another = linkonce_odr unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr @_ZTch0_h8_NK13SpecialSource7PointerEv, ptr @_ZTch0_h8_NK13SpecialSource9ReferenceEv, ptr @_ZNK13SpecialSource7PointerEv, ptr @_ZNK13SpecialSource9ReferenceEv] }, align 8

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN5LocalC2Ev(ptr noundef nonnull returned align 8 dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN13SpecialSourceC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1)
  store ptr getelementptr inbounds inrange(-16, 32) ({ [6 x ptr] }, ptr @_ZTV5Local, i32 0, i32 0, i32 2), ptr %this1, align 8
  ret ptr %this1
}

declare noundef ptr @_ZN13SpecialSourceC2Ev(ptr noundef nonnull returned align 8 dereferenceable(8)) unnamed_addr #1

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN5LocalC1Ev(ptr noundef nonnull returned align 8 dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5LocalC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN5LocalD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN13SpecialSourceD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  ret ptr %this1
}

; Function Attrs: nounwind
declare noundef ptr @_ZN13SpecialSourceD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8)) unnamed_addr #3

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN5LocalD1Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5LocalD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_Z11PointerCallRK6Source(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %0, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 0
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef ptr %1(ptr noundef nonnull align 8 dereferenceable(8) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z13ReferenceCallRK6Source(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %0, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 1
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %1(ptr noundef nonnull align 8 dereferenceable(8) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7AnotherC2Ev(ptr noundef nonnull returned align 8 dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN13SpecialSourceC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1)
  store ptr getelementptr inbounds inrange(-16, 32) ({ [6 x ptr] }, ptr @_ZTV7Another, i32 0, i32 0, i32 2), ptr %this1, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7AnotherC1Ev(ptr noundef nonnull returned align 8 dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7AnotherC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7AnotherD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN13SpecialSourceD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7AnotherD1Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7AnotherD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  ret ptr %this1
}

declare noundef ptr @_ZTch0_h8_NK13SpecialSource7PointerEv(ptr noundef) unnamed_addr #1

declare noundef ptr @_ZTch0_h8_NK13SpecialSource9ReferenceEv(ptr noundef) unnamed_addr #1

declare noundef ptr @_ZNK13SpecialSource7PointerEv(ptr noundef nonnull align 8 dereferenceable(8)) unnamed_addr #1

declare noundef nonnull align 8 dereferenceable(12) ptr @_ZNK13SpecialSource9ReferenceEv(ptr noundef nonnull align 8 dereferenceable(8)) unnamed_addr #1

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 8}
