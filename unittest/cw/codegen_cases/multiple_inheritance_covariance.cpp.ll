; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti multiple_inheritance_covariance.cpp -o -
; ModuleID = 'multiple_inheritance_covariance.cpp'
source_filename = "multiple_inheritance_covariance.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Factory = type { %struct.Plain, %struct.Maker, ptr }
%struct.Plain = type { ptr }
%struct.Maker = type { ptr }

@_ZTV7Factory = unnamed_addr constant { [7 x ptr], [4 x ptr] } { [7 x ptr] [ptr null, ptr null, ptr @_ZNK5Plain2IdEv, ptr @_ZTch0_h4_NK7Factory4ItemEv, ptr @_ZNK7Factory4MakeEv, ptr @_ZNK7Factory3GetEv, ptr @_ZNK7Factory4ItemEv], [4 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr @_ZTchn8_h4_NK7Factory4MakeEv, ptr @_ZTchn8_h4_NK7Factory3GetEv] }, align 8

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZNK7Factory4MakeEv(ptr noundef nonnull align 8 dereferenceable(24) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.Factory, ptr %this1, i32 0, i32 2
  %0 = load ptr, ptr %target, align 8
  ret ptr %0
}

; Function Attrs: noinline optnone ssp uwtable(sync)
define noundef ptr @_ZTchn8_h4_NK7Factory4MakeEv(ptr noundef %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 -8
  %call = call noundef ptr @_ZNK7Factory4MakeEv(ptr noundef nonnull align 8 dereferenceable(24) %0)
  %1 = icmp eq ptr %call, null
  br i1 %1, label %adjust.null, label %adjust.notnull

adjust.notnull:                                   ; preds = %entry
  %2 = getelementptr inbounds i8, ptr %call, i64 4
  br label %adjust.end

adjust.null:                                      ; preds = %entry
  br label %adjust.end

adjust.end:                                       ; preds = %adjust.null, %adjust.notnull
  %3 = phi ptr [ %2, %adjust.notnull ], [ null, %adjust.null ]
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_ZNK7Factory3GetEv(ptr noundef nonnull align 8 dereferenceable(24) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.Factory, ptr %this1, i32 0, i32 2
  %0 = load ptr, ptr %target, align 8
  ret ptr %0
}

; Function Attrs: noinline optnone ssp uwtable(sync)
define noundef ptr @_ZTchn8_h4_NK7Factory3GetEv(ptr noundef %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 -8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @_ZNK7Factory3GetEv(ptr noundef nonnull align 8 dereferenceable(24) %0)
  %1 = getelementptr inbounds i8, ptr %call, i64 4
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZNK7Factory4ItemEv(ptr noundef nonnull align 8 dereferenceable(24) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.Factory, ptr %this1, i32 0, i32 2
  %0 = load ptr, ptr %target, align 8
  ret ptr %0
}

; Function Attrs: noinline optnone ssp uwtable(sync)
define noundef ptr @_ZTch0_h4_NK7Factory4ItemEv(ptr noundef %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZNK7Factory4ItemEv(ptr noundef nonnull align 8 dereferenceable(24) %this1)
  %0 = icmp eq ptr %call, null
  br i1 %0, label %adjust.null, label %adjust.notnull

adjust.notnull:                                   ; preds = %entry
  %1 = getelementptr inbounds i8, ptr %call, i64 4
  br label %adjust.end

adjust.null:                                      ; preds = %entry
  br label %adjust.end

adjust.end:                                       ; preds = %adjust.null, %adjust.notnull
  %2 = phi ptr [ %1, %adjust.notnull ], [ null, %adjust.null ]
  ret ptr %2
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7FactoryC2EP7Special(ptr noundef nonnull returned align 8 dereferenceable(24) %this, ptr noundef %input) unnamed_addr #2 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %input, ptr %input.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5PlainC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1)
  %0 = getelementptr inbounds i8, ptr %this1, i64 8
  %call2 = invoke noundef ptr @_ZN5MakerC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %0)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  store ptr getelementptr inbounds inrange(-16, 40) ({ [7 x ptr], [4 x ptr] }, ptr @_ZTV7Factory, i32 0, i32 0, i32 2), ptr %this1, align 8
  %add.ptr = getelementptr inbounds i8, ptr %this1, i64 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [7 x ptr], [4 x ptr] }, ptr @_ZTV7Factory, i32 0, i32 1, i32 2), ptr %add.ptr, align 8
  %target = getelementptr inbounds nuw %struct.Factory, ptr %this1, i32 0, i32 2
  %1 = load ptr, ptr %input.addr, align 8
  store ptr %1, ptr %target, align 8
  ret ptr %this1

lpad:                                             ; preds = %entry
  %2 = landingpad { ptr, i32 }
          cleanup
  %3 = extractvalue { ptr, i32 } %2, 0
  store ptr %3, ptr %exn.slot, align 8
  %4 = extractvalue { ptr, i32 } %2, 1
  store i32 %4, ptr %ehselector.slot, align 4
  %call3 = call noundef ptr @_ZN5PlainD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #5
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val4 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val4
}

declare noundef ptr @_ZN5PlainC2Ev(ptr noundef nonnull returned align 8 dereferenceable(8)) unnamed_addr #3

declare noundef ptr @_ZN5MakerC2Ev(ptr noundef nonnull returned align 8 dereferenceable(8)) unnamed_addr #3

declare i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind
declare noundef ptr @_ZN5PlainD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8)) unnamed_addr #4

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7FactoryC1EP7Special(ptr noundef nonnull returned align 8 dereferenceable(24) %this, ptr noundef %input) unnamed_addr #2 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %input, ptr %input.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %input.addr, align 8
  %call = call noundef ptr @_ZN7FactoryC2EP7Special(ptr noundef nonnull align 8 dereferenceable(24) %this1, ptr noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7FactoryD2Ev(ptr noundef nonnull returned align 8 dead_on_return(24) dereferenceable(24) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 8
  %call = call noundef ptr @_ZN5MakerD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %0) #5
  %call2 = call noundef ptr @_ZN5PlainD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #5
  ret ptr %this1
}

; Function Attrs: nounwind
declare noundef ptr @_ZN5MakerD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8)) unnamed_addr #4

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7FactoryD1Ev(ptr noundef nonnull returned align 8 dead_on_return(24) dereferenceable(24) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7FactoryD2Ev(ptr noundef nonnull align 8 dead_on_return(24) dereferenceable(24) %this1) #5
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_Z11MakeThroughRK5Maker(ptr noundef nonnull align 8 dereferenceable(8) %maker) #2 {
entry:
  %maker.addr = alloca ptr, align 8
  store ptr %maker, ptr %maker.addr, align 8
  %0 = load ptr, ptr %maker.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %0, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 0
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef ptr %1(ptr noundef nonnull align 8 dereferenceable(8) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z10GetThroughRK5Maker(ptr noundef nonnull align 8 dereferenceable(8) %maker) #2 {
entry:
  %maker.addr = alloca ptr, align 8
  store ptr %maker, ptr %maker.addr, align 8
  %0 = load ptr, ptr %maker.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %0, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 1
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %1(ptr noundef nonnull align 8 dereferenceable(8) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_Z10MakeDirectRK7Factory(ptr noundef nonnull align 8 dereferenceable(24) %factory) #2 {
entry:
  %factory.addr = alloca ptr, align 8
  store ptr %factory, ptr %factory.addr, align 8
  %0 = load ptr, ptr %factory.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %0, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 2
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef ptr %1(ptr noundef nonnull align 8 dereferenceable(24) %0)
  ret ptr %call
}

declare noundef i32 @_ZNK5Plain2IdEv(ptr noundef nonnull align 8 dereferenceable(8)) unnamed_addr #3

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
