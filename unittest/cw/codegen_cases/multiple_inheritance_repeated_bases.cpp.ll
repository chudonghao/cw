; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti multiple_inheritance_repeated_bases.cpp -o -
; ModuleID = 'multiple_inheritance_repeated_bases.cpp'
source_filename = "multiple_inheritance_repeated_bases.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@_ZTV1D = unnamed_addr constant { [4 x ptr], [4 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @_ZNK1B1FEv, ptr @_ZNK1D1GEv], [4 x ptr] [ptr inttoptr (i64 -16 to ptr), ptr null, ptr @_ZNK1A1FEv, ptr @_ZThn16_NK1D1GEv] }, align 8

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK1D1GEv(ptr noundef nonnull align 8 dereferenceable(28) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret i32 4
}

; Function Attrs: noinline optnone ssp uwtable(sync)
define noundef i32 @_ZThn16_NK1D1GEv(ptr noundef %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 -16
  %call = tail call noundef i32 @_ZNK1D1GEv(ptr noundef nonnull align 8 dereferenceable(28) %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN1DC2Ev(ptr noundef nonnull returned align 8 dereferenceable(28) %this) unnamed_addr #2 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN1BC2Ev(ptr noundef nonnull align 8 dereferenceable(12) %this1)
  %0 = getelementptr inbounds i8, ptr %this1, i64 16
  %call2 = invoke noundef ptr @_ZN1CC2Ev(ptr noundef nonnull align 8 dereferenceable(12) %0)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @_ZTV1D, i32 0, i32 0, i32 2), ptr %this1, align 8
  %add.ptr = getelementptr inbounds i8, ptr %this1, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @_ZTV1D, i32 0, i32 1, i32 2), ptr %add.ptr, align 8
  ret ptr %this1

lpad:                                             ; preds = %entry
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  store ptr %2, ptr %exn.slot, align 8
  %3 = extractvalue { ptr, i32 } %1, 1
  store i32 %3, ptr %ehselector.slot, align 4
  %call3 = call noundef ptr @_ZN1BD2Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %this1) #5
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val4 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val4
}

declare noundef ptr @_ZN1BC2Ev(ptr noundef nonnull returned align 8 dereferenceable(12)) unnamed_addr #3

declare noundef ptr @_ZN1CC2Ev(ptr noundef nonnull returned align 8 dereferenceable(12)) unnamed_addr #3

declare i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind
declare noundef ptr @_ZN1BD2Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12)) unnamed_addr #4

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN1DC1Ev(ptr noundef nonnull returned align 8 dereferenceable(28) %this) unnamed_addr #2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN1DC2Ev(ptr noundef nonnull align 8 dereferenceable(28) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN1DD2Ev(ptr noundef nonnull returned align 8 dead_on_return(28) dereferenceable(28) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 16
  %call = call noundef ptr @_ZN1CD2Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %0) #5
  %call2 = call noundef ptr @_ZN1BD2Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %this1) #5
  ret ptr %this1
}

; Function Attrs: nounwind
declare noundef ptr @_ZN1CD2Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12)) unnamed_addr #4

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN1DD1Ev(ptr noundef nonnull returned align 8 dead_on_return(28) dereferenceable(28) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN1DD2Ev(ptr noundef nonnull align 8 dead_on_return(28) dereferenceable(28) %this1) #5
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z12ReadThroughCRK1D(ptr noundef nonnull align 8 dereferenceable(28) %d) #2 {
entry:
  %d.addr = alloca ptr, align 8
  %c = alloca ptr, align 8
  store ptr %d, ptr %d.addr, align 8
  %0 = load ptr, ptr %d.addr, align 8, !nonnull !5, !align !6
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 16
  store ptr %add.ptr, ptr %c, align 8
  %1 = load ptr, ptr %c, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %1, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 0
  %2 = load ptr, ptr %vfn, align 8
  %call = call noundef i32 %2(ptr noundef nonnull align 8 dereferenceable(12) %1)
  %3 = load ptr, ptr %c, align 8, !nonnull !5, !align !6
  %vtable1 = load ptr, ptr %3, align 8
  %vfn2 = getelementptr inbounds ptr, ptr %vtable1, i64 1
  %4 = load ptr, ptr %vfn2, align 8
  %call3 = call noundef i32 %4(ptr noundef nonnull align 8 dereferenceable(12) %3)
  %add = add nsw i32 %call, %call3
  ret i32 %add
}

declare noundef i32 @_ZNK1B1FEv(ptr noundef nonnull align 8 dereferenceable(12)) unnamed_addr #3

declare noundef i32 @_ZNK1A1FEv(ptr noundef nonnull align 8 dereferenceable(12)) unnamed_addr #3

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #4 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 4]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.5"}
!5 = !{}
!6 = !{i64 8}
