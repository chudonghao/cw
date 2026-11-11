; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti import_multiple_inheritance.cpp -o -
; ModuleID = 'import_multiple_inheritance.cpp'
source_filename = "import_multiple_inheritance.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@_ZTV7Derived = unnamed_addr constant { [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @_ZNK7Derived3OneEv, ptr @_ZNK3api4Pair3TwoEv], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr @_ZThn8_NK3api4Pair3TwoEv] }, align 8

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK7Derived3OneEv(ptr noundef nonnull align 8 dereferenceable(20) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret i32 1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedC2Ev(ptr noundef nonnull returned align 8 dereferenceable(20) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN3api4PairC2Ev(ptr noundef nonnull align 8 dereferenceable(20) %this1)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @_ZTV7Derived, i32 0, i32 0, i32 2), ptr %this1, align 8
  %add.ptr = getelementptr inbounds i8, ptr %this1, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @_ZTV7Derived, i32 0, i32 1, i32 2), ptr %add.ptr, align 8
  ret ptr %this1
}

declare noundef ptr @_ZN3api4PairC2Ev(ptr noundef nonnull returned align 8 dereferenceable(20)) unnamed_addr #2

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedC1Ev(ptr noundef nonnull returned align 8 dereferenceable(20) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7DerivedC2Ev(ptr noundef nonnull align 8 dereferenceable(20) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedD2Ev(ptr noundef nonnull returned align 8 dead_on_return(20) dereferenceable(20) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN3api4PairD2Ev(ptr noundef nonnull align 8 dead_on_return(20) dereferenceable(20) %this1) #4
  ret ptr %this1
}

; Function Attrs: nounwind
declare noundef ptr @_ZN3api4PairD2Ev(ptr noundef nonnull returned align 8 dead_on_return(20) dereferenceable(20)) unnamed_addr #3

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedD1Ev(ptr noundef nonnull returned align 8 dead_on_return(20) dereferenceable(20) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7DerivedD2Ev(ptr noundef nonnull align 8 dead_on_return(20) dereferenceable(20) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z10CallSecondRKN3api4PairE(ptr noundef nonnull align 8 dereferenceable(20) %pair) #1 {
entry:
  %pair.addr = alloca ptr, align 8
  store ptr %pair, ptr %pair.addr, align 8
  %0 = load ptr, ptr %pair.addr, align 8, !nonnull !5, !align !6
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 8
  %vtable = load ptr, ptr %add.ptr, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 0
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef i32 %1(ptr noundef nonnull align 8 dereferenceable(12) %add.ptr)
  ret i32 %call
}

declare noundef i32 @_ZNK3api4Pair3TwoEv(ptr noundef nonnull align 8 dereferenceable(20)) unnamed_addr #2

declare noundef i32 @_ZThn8_NK3api4Pair3TwoEv(ptr noundef) unnamed_addr #2

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 4]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.5"}
!5 = !{}
!6 = !{i64 8}
