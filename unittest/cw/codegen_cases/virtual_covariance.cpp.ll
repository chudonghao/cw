; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti virtual_covariance.cpp -o -
; ModuleID = 'virtual_covariance.cpp'
source_filename = "virtual_covariance.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Product = type { i32 }
%struct.SpecialSource = type { %struct.Source, ptr }
%struct.Source = type { ptr }
%struct.SpecialProduct = type <{ ptr, %struct.Product, [4 x i8] }>

@_ZTV14SpecialProduct = unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr @_ZNK14SpecialProduct3TagEv] }, align 8
@_ZTV6Source = linkonce_odr unnamed_addr constant { [4 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @__cxa_pure_virtual, ptr @__cxa_pure_virtual] }, align 8
@_ZTV13SpecialSource = unnamed_addr constant { [6 x ptr] } { [6 x ptr] [ptr null, ptr null, ptr @_ZTch0_h8_NK13SpecialSource7PointerEv, ptr @_ZTch0_h8_NK13SpecialSource9ReferenceEv, ptr @_ZNK13SpecialSource7PointerEv, ptr @_ZNK13SpecialSource9ReferenceEv] }, align 8

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7ProductC2Ev(ptr noundef nonnull returned align 4 dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Product, ptr %this1, i32 0, i32 0
  store i32 42, ptr %value, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7ProductC1Ev(ptr noundef nonnull returned align 4 dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7ProductC2Ev(ptr noundef nonnull align 4 dereferenceable(4) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7ProductD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7ProductD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7ProductD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK14SpecialProduct3TagEv(ptr noundef nonnull align 8 dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret i32 7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN14SpecialProductC2Ev(ptr noundef nonnull returned align 8 dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 8
  %call = call noundef ptr @_ZN7ProductC2Ev(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @_ZTV14SpecialProduct, i32 0, i32 0, i32 2), ptr %this1, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN14SpecialProductC1Ev(ptr noundef nonnull returned align 8 dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN14SpecialProductC2Ev(ptr noundef nonnull align 8 dereferenceable(12) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN14SpecialProductD2Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = getelementptr inbounds i8, ptr %this1, i64 8
  %call = call noundef ptr @_ZN7ProductD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %0) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN14SpecialProductD1Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN14SpecialProductD2Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZNK13SpecialSource7PointerEv(ptr noundef nonnull align 8 dereferenceable(16) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.SpecialSource, ptr %this1, i32 0, i32 1
  %0 = load ptr, ptr %target, align 8
  ret ptr %0
}

; Function Attrs: noinline optnone ssp uwtable(sync)
define noundef ptr @_ZTch0_h8_NK13SpecialSource7PointerEv(ptr noundef %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZNK13SpecialSource7PointerEv(ptr noundef nonnull align 8 dereferenceable(16) %this1)
  %0 = icmp eq ptr %call, null
  br i1 %0, label %adjust.null, label %adjust.notnull

adjust.notnull:                                   ; preds = %entry
  %1 = getelementptr inbounds i8, ptr %call, i64 8
  br label %adjust.end

adjust.null:                                      ; preds = %entry
  br label %adjust.end

adjust.end:                                       ; preds = %adjust.null, %adjust.notnull
  %2 = phi ptr [ %1, %adjust.notnull ], [ null, %adjust.null ]
  ret ptr %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(12) ptr @_ZNK13SpecialSource9ReferenceEv(ptr noundef nonnull align 8 dereferenceable(16) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.SpecialSource, ptr %this1, i32 0, i32 1
  %0 = load ptr, ptr %target, align 8
  ret ptr %0
}

; Function Attrs: noinline optnone ssp uwtable(sync)
define noundef ptr @_ZTch0_h8_NK13SpecialSource9ReferenceEv(ptr noundef %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef nonnull align 8 dereferenceable(12) ptr @_ZNK13SpecialSource9ReferenceEv(ptr noundef nonnull align 8 dereferenceable(16) %this1)
  %0 = getelementptr inbounds i8, ptr %call, i64 8
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN6SourceC2Ev(ptr noundef nonnull returned align 8 dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr] }, ptr @_ZTV6Source, i32 0, i32 0, i32 2), ptr %this1, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN6SourceD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN6SourceD1Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  call void @llvm.trap() #5
  unreachable
}

; Function Attrs: cold noreturn nounwind memory(inaccessiblemem: write)
declare void @llvm.trap() #2

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN13SpecialSourceC2EP14SpecialProduct(ptr noundef nonnull returned align 8 dereferenceable(16) %this, ptr noundef %input) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %input, ptr %input.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN6SourceC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1)
  store ptr getelementptr inbounds inrange(-16, 32) ({ [6 x ptr] }, ptr @_ZTV13SpecialSource, i32 0, i32 0, i32 2), ptr %this1, align 8
  %target = getelementptr inbounds nuw %struct.SpecialSource, ptr %this1, i32 0, i32 1
  %0 = load ptr, ptr %input.addr, align 8
  store ptr %0, ptr %target, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN13SpecialSourceC1EP14SpecialProduct(ptr noundef nonnull returned align 8 dereferenceable(16) %this, ptr noundef %input) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %input, ptr %input.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %input.addr, align 8
  %call = call noundef ptr @_ZN13SpecialSourceC2EP14SpecialProduct(ptr noundef nonnull align 8 dereferenceable(16) %this1, ptr noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN13SpecialSourceD2Ev(ptr noundef nonnull returned align 8 dead_on_return(16) dereferenceable(16) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN6SourceD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN13SpecialSourceD1Ev(ptr noundef nonnull returned align 8 dead_on_return(16) dereferenceable(16) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN13SpecialSourceD2Ev(ptr noundef nonnull align 8 dead_on_return(16) dereferenceable(16) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_Z10GetPointerRK6Source(ptr noundef nonnull align 8 dereferenceable(8) %source) #3 {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %0, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 0
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef ptr %1(ptr noundef nonnull align 8 dereferenceable(8) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z12GetReferenceRK6Source(ptr noundef nonnull align 8 dereferenceable(8) %source) #3 {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %0, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 1
  %1 = load ptr, ptr %vfn, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %1(ptr noundef nonnull align 8 dereferenceable(8) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z5Checkv() #3 personality ptr @__gxx_personality_v0 {
entry:
  %product = alloca %struct.SpecialProduct, align 8
  %source = alloca %struct.SpecialSource, align 8
  %empty = alloca %struct.SpecialSource, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %call = call noundef ptr @_ZN14SpecialProductC1Ev(ptr noundef nonnull align 8 dereferenceable(12) %product)
  %call1 = call noundef ptr @_ZN13SpecialSourceC1EP14SpecialProduct(ptr noundef nonnull align 8 dereferenceable(16) %source, ptr noundef %product)
  %call2 = call noundef ptr @_ZN13SpecialSourceC1EP14SpecialProduct(ptr noundef nonnull align 8 dereferenceable(16) %empty, ptr noundef null)
  %call3 = invoke noundef ptr @_Z10GetPointerRK6Source(ptr noundef nonnull align 8 dereferenceable(8) %source)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %0 = icmp eq ptr %product, null
  br i1 %0, label %cast.end, label %cast.notnull

cast.notnull:                                     ; preds = %invoke.cont
  %add.ptr = getelementptr inbounds i8, ptr %product, i64 8
  br label %cast.end

cast.end:                                         ; preds = %cast.notnull, %invoke.cont
  %cast.result = phi ptr [ %add.ptr, %cast.notnull ], [ null, %invoke.cont ]
  %cmp = icmp eq ptr %call3, %cast.result
  br i1 %cmp, label %land.lhs.true, label %land.end

land.lhs.true:                                    ; preds = %cast.end
  %call5 = invoke noundef nonnull align 4 dereferenceable(4) ptr @_Z12GetReferenceRK6Source(ptr noundef nonnull align 8 dereferenceable(8) %source)
          to label %invoke.cont4 unwind label %lpad

invoke.cont4:                                     ; preds = %land.lhs.true
  %1 = icmp eq ptr %product, null
  br i1 %1, label %cast.end8, label %cast.notnull6

cast.notnull6:                                    ; preds = %invoke.cont4
  %add.ptr7 = getelementptr inbounds i8, ptr %product, i64 8
  br label %cast.end8

cast.end8:                                        ; preds = %cast.notnull6, %invoke.cont4
  %cast.result9 = phi ptr [ %add.ptr7, %cast.notnull6 ], [ null, %invoke.cont4 ]
  %cmp10 = icmp eq ptr %call5, %cast.result9
  br i1 %cmp10, label %land.lhs.true11, label %land.end

land.lhs.true11:                                  ; preds = %cast.end8
  %call13 = invoke noundef ptr @_Z10GetPointerRK6Source(ptr noundef nonnull align 8 dereferenceable(8) %empty)
          to label %invoke.cont12 unwind label %lpad

invoke.cont12:                                    ; preds = %land.lhs.true11
  %cmp14 = icmp eq ptr %call13, null
  br i1 %cmp14, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %invoke.cont12
  %call15 = call noundef ptr @_ZNK13SpecialSource7PointerEv(ptr noundef nonnull align 8 dereferenceable(16) %source)
  %cmp16 = icmp eq ptr %call15, %product
  br label %land.end

land.end:                                         ; preds = %land.rhs, %invoke.cont12, %cast.end8, %cast.end
  %2 = phi i1 [ false, %invoke.cont12 ], [ false, %cast.end8 ], [ false, %cast.end ], [ %cmp16, %land.rhs ]
  %call17 = call noundef ptr @_ZN13SpecialSourceD1Ev(ptr noundef nonnull align 8 dead_on_return(16) dereferenceable(16) %empty) #4
  %call19 = call noundef ptr @_ZN13SpecialSourceD1Ev(ptr noundef nonnull align 8 dead_on_return(16) dereferenceable(16) %source) #4
  %call21 = call noundef ptr @_ZN14SpecialProductD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %product) #4
  ret i1 %2

lpad:                                             ; preds = %land.lhs.true11, %land.lhs.true, %entry
  %3 = landingpad { ptr, i32 }
          cleanup
  %4 = extractvalue { ptr, i32 } %3, 0
  store ptr %4, ptr %exn.slot, align 8
  %5 = extractvalue { ptr, i32 } %3, 1
  store i32 %5, ptr %ehselector.slot, align 4
  %call18 = call noundef ptr @_ZN13SpecialSourceD1Ev(ptr noundef nonnull align 8 dead_on_return(16) dereferenceable(16) %empty) #4
  %call20 = call noundef ptr @_ZN13SpecialSourceD1Ev(ptr noundef nonnull align 8 dead_on_return(16) dereferenceable(16) %source) #4
  %call22 = call noundef ptr @_ZN14SpecialProductD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %product) #4
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val23 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val23
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z14ConvertPointerP14SpecialProduct(ptr noundef %product) #0 {
entry:
  %product.addr = alloca ptr, align 8
  store ptr %product, ptr %product.addr, align 8
  %0 = load ptr, ptr %product.addr, align 8
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cast.end, label %cast.notnull

cast.notnull:                                     ; preds = %entry
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 8
  br label %cast.end

cast.end:                                         ; preds = %cast.notnull, %entry
  %cast.result = phi ptr [ %add.ptr, %cast.notnull ], [ null, %entry ]
  ret ptr %cast.result
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z16ConvertReferenceRK14SpecialProduct(ptr noundef nonnull align 8 dereferenceable(12) %product) #0 {
entry:
  %product.addr = alloca ptr, align 8
  store ptr %product, ptr %product.addr, align 8
  %0 = load ptr, ptr %product.addr, align 8, !nonnull !5, !align !6
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 8
  ret ptr %add.ptr
}

declare void @__cxa_pure_virtual() unnamed_addr

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { cold noreturn nounwind memory(inaccessiblemem: write) }
attributes #3 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #4 = { nounwind }
attributes #5 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 8}
