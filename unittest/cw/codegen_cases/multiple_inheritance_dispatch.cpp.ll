; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti multiple_inheritance_dispatch.cpp -o -
; ModuleID = 'multiple_inheritance_dispatch.cpp'
source_filename = "multiple_inheritance_dispatch.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@_ZTV4Both = unnamed_addr constant { [4 x ptr], [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @_ZNK4Both4NameEv, ptr @_ZNK4Both4SizeEv], [4 x ptr] [ptr inttoptr (i64 -16 to ptr), ptr null, ptr @_ZThn16_NK4Both4SizeEv, ptr @_ZThn16_NK4Both4NameEv], [3 x ptr] [ptr inttoptr (i64 -24 to ptr), ptr null, ptr @__cxa_pure_virtual] }, align 8
@_ZTV5Child = linkonce_odr unnamed_addr constant { [4 x ptr], [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @_ZNK4Both4NameEv, ptr @_ZNK4Both4SizeEv], [4 x ptr] [ptr inttoptr (i64 -16 to ptr), ptr null, ptr @_ZThn16_NK4Both4SizeEv, ptr @_ZThn16_NK4Both4NameEv], [3 x ptr] [ptr inttoptr (i64 -24 to ptr), ptr null, ptr @__cxa_pure_virtual] }, align 8

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK4Both4NameEv(ptr noundef nonnull align 8 dereferenceable(36) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret i32 1
}

; Function Attrs: noinline optnone ssp uwtable(sync)
define noundef i32 @_ZThn16_NK4Both4NameEv(ptr noundef %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 -16
  %call = tail call noundef i32 @_ZNK4Both4NameEv(ptr noundef nonnull align 8 dereferenceable(36) %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK4Both4SizeEv(ptr noundef nonnull align 8 dereferenceable(36) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret i32 2
}

; Function Attrs: noinline optnone ssp uwtable(sync)
define noundef i32 @_ZThn16_NK4Both4SizeEv(ptr noundef %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 -16
  %call = tail call noundef i32 @_ZNK4Both4SizeEv(ptr noundef nonnull align 8 dereferenceable(36) %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN4BothC2Ev(ptr noundef nonnull returned align 8 dereferenceable(36) %this) unnamed_addr #2 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4LeftC2Ev(ptr noundef nonnull align 8 dereferenceable(12) %this1)
  %0 = getelementptr inbounds i8, ptr %this1, i64 16
  %call2 = invoke noundef ptr @_ZN5RightC2Ev(ptr noundef nonnull align 8 dereferenceable(20) %0)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @_ZTV4Both, i32 0, i32 0, i32 2), ptr %this1, align 8
  %add.ptr = getelementptr inbounds i8, ptr %this1, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @_ZTV4Both, i32 0, i32 1, i32 2), ptr %add.ptr, align 8
  %add.ptr3 = getelementptr inbounds i8, ptr %this1, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @_ZTV4Both, i32 0, i32 2, i32 2), ptr %add.ptr3, align 8
  ret ptr %this1

lpad:                                             ; preds = %entry
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  store ptr %2, ptr %exn.slot, align 8
  %3 = extractvalue { ptr, i32 } %1, 1
  store i32 %3, ptr %ehselector.slot, align 4
  %call4 = call noundef ptr @_ZN4LeftD2Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %this1) #6
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val5 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val5
}

declare noundef ptr @_ZN4LeftC2Ev(ptr noundef nonnull returned align 8 dereferenceable(12)) unnamed_addr #3

declare noundef ptr @_ZN5RightC2Ev(ptr noundef nonnull returned align 8 dereferenceable(20)) unnamed_addr #3

declare i32 @__gxx_personality_v0(...)

; Function Attrs: nounwind
declare noundef ptr @_ZN4LeftD2Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12)) unnamed_addr #4

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4BothD2Ev(ptr noundef nonnull returned align 8 dead_on_return(36) dereferenceable(36) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 16
  %call = call noundef ptr @_ZN5RightD2Ev(ptr noundef nonnull align 8 dead_on_return(20) dereferenceable(20) %0) #6
  %call2 = call noundef ptr @_ZN4LeftD2Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %this1) #6
  ret ptr %this1
}

; Function Attrs: nounwind
declare noundef ptr @_ZN5RightD2Ev(ptr noundef nonnull returned align 8 dead_on_return(20) dereferenceable(20)) unnamed_addr #4

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4BothD1Ev(ptr noundef nonnull returned align 8 dead_on_return(36) dereferenceable(36) %this) unnamed_addr #0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  call void @llvm.trap() #7
  unreachable
}

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #5

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN5ChildC2Ev(ptr noundef nonnull returned align 8 dereferenceable(36) %this) unnamed_addr #2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4BothC2Ev(ptr noundef nonnull align 8 dereferenceable(36) %this1)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @_ZTV5Child, i32 0, i32 0, i32 2), ptr %this1, align 8
  %add.ptr = getelementptr inbounds i8, ptr %this1, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @_ZTV5Child, i32 0, i32 1, i32 2), ptr %add.ptr, align 8
  %add.ptr2 = getelementptr inbounds i8, ptr %this1, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @_ZTV5Child, i32 0, i32 2, i32 2), ptr %add.ptr2, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN5ChildD2Ev(ptr noundef nonnull returned align 8 dead_on_return(36) dereferenceable(36) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4BothD2Ev(ptr noundef nonnull align 8 dead_on_return(36) dereferenceable(36) %this1) #6
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN5ChildD1Ev(ptr noundef nonnull returned align 8 dead_on_return(36) dereferenceable(36) %this) unnamed_addr #0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  call void @llvm.trap() #7
  unreachable
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8ReadDeepRK4Both(ptr noundef nonnull align 8 dereferenceable(36) %both) #2 {
entry:
  %both.addr = alloca ptr, align 8
  store ptr %both, ptr %both.addr, align 8
  %0 = load ptr, ptr %both.addr, align 8, !nonnull !5, !align !6
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 24
  %vtable = load ptr, ptr %add.ptr, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 0
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef i32 %1(ptr noundef nonnull align 8 dereferenceable(8) %add.ptr)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z10ViaPointerRK4Both(ptr noundef nonnull align 8 dereferenceable(36) %both) #2 {
entry:
  %both.addr = alloca ptr, align 8
  %size = alloca { i64, i64 }, align 8
  store ptr %both, ptr %both.addr, align 8
  store { i64, i64 } { i64 0, i64 1 }, ptr %size, align 8
  %0 = load ptr, ptr %both.addr, align 8, !nonnull !5, !align !6
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 16
  %1 = load { i64, i64 }, ptr %size, align 8
  %memptr.adj = extractvalue { i64, i64 } %1, 1
  %memptr.adj.shifted = ashr i64 %memptr.adj, 1
  %2 = getelementptr inbounds i8, ptr %add.ptr, i64 %memptr.adj.shifted
  %memptr.ptr = extractvalue { i64, i64 } %1, 0
  %3 = and i64 %memptr.adj, 1
  %memptr.isvirtual = icmp ne i64 %3, 0
  br i1 %memptr.isvirtual, label %memptr.virtual, label %memptr.nonvirtual

memptr.virtual:                                   ; preds = %entry
  %vtable = load ptr, ptr %2, align 8
  %4 = trunc i64 %memptr.ptr to i32
  %5 = zext i32 %4 to i64
  %6 = getelementptr i8, ptr %vtable, i64 %5, !nosanitize !5
  %memptr.virtualfn = load ptr, ptr %6, align 8, !nosanitize !5
  br label %memptr.end

memptr.nonvirtual:                                ; preds = %entry
  %memptr.nonvirtualfn = inttoptr i64 %memptr.ptr to ptr
  br label %memptr.end

memptr.end:                                       ; preds = %memptr.nonvirtual, %memptr.virtual
  %7 = phi ptr [ %memptr.virtualfn, %memptr.virtual ], [ %memptr.nonvirtualfn, %memptr.nonvirtual ]
  %call = call noundef i32 %7(ptr noundef nonnull align 8 dereferenceable(8) %2)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z6DirectRK4Both(ptr noundef nonnull align 8 dereferenceable(36) %both) #2 {
entry:
  %both.addr = alloca ptr, align 8
  store ptr %both, ptr %both.addr, align 8
  %0 = load ptr, ptr %both.addr, align 8, !nonnull !5, !align !6
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 16
  %call = call noundef i32 @_ZNK5Right4NameEv(ptr noundef nonnull align 8 dereferenceable(20) %add.ptr)
  ret i32 %call
}

declare noundef i32 @_ZNK5Right4NameEv(ptr noundef nonnull align 8 dereferenceable(20)) unnamed_addr #3

declare void @__cxa_pure_virtual() unnamed_addr

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #4 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #5 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #6 = { nounwind }
attributes #7 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 4]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.5"}
!5 = !{}
!6 = !{i64 8}
