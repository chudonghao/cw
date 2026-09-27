; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names global_lifetimes.cpp -o -
; ModuleID = 'global_lifetimes.cpp'
source_filename = "global_lifetimes.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Globals = type { %struct.Item, %struct.Item }
%struct.Item = type { i32 }
%class.anon = type { i8 }
%class.anon.0 = type { i8 }

@trace = global i64 0, align 8
@values = global %struct.Globals zeroinitializer, align 4
@__dso_handle = external hidden global i8
@pair = global [2 x %struct.Item] zeroinitializer, align 4
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_global_lifetimes.cpp, ptr null }]

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z4Marki(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i64, ptr @trace, align 8
  %mul = mul nsw i64 %0, 10
  %1 = load i32, ptr %value.addr, align 4
  %conv = sext i32 %1 to i64
  %add = add nsw i64 %mul, %conv
  store i64 %add, ptr @trace, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z4Flagv() #0 {
entry:
  ret i1 true
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7ObserveRK4Item(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  call void @_Z4Marki(i32 noundef %1)
  ret void
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_var_init() #1 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  %ref.tmp = alloca %class.anon, align 1
  call void @"_ZNK3$_0clEv"(ptr dead_on_unwind writable sret(%struct.Globals) align 4 @values, ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  %0 = call i32 @__cxa_atexit(ptr @_ZN7GlobalsD1Ev, ptr @values, ptr @__dso_handle) #3
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define internal void @"_ZNK3$_0clEv"(ptr dead_on_unwind noalias writable sret(%struct.Globals) align 4 %agg.result, ptr noundef nonnull align 1 dereferenceable(1) %this) #2 personality ptr @__gxx_personality_v0 {
entry:
  %result.ptr = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %local = alloca %struct.Item, align 4
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %ref.tmp = alloca %class.anon.0, align 1
  store ptr %agg.result, ptr %result.ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %local, i32 noundef 1)
  %first = getelementptr inbounds nuw %struct.Globals, ptr %agg.result, i32 0, i32 0
  %call2 = call noundef zeroext i1 @_Z4Flagv()
  br i1 %call2, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %call3 = invoke noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %first, i32 noundef 2)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %cond.true
  br label %cond.end

cond.false:                                       ; preds = %entry
  %call5 = invoke noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %first, i32 noundef 3)
          to label %invoke.cont4 unwind label %lpad

invoke.cont4:                                     ; preds = %cond.false
  br label %cond.end

cond.end:                                         ; preds = %invoke.cont4, %invoke.cont
  %second = getelementptr inbounds nuw %struct.Globals, ptr %agg.result, i32 0, i32 1
  invoke void @"_ZZNK3$_0clEvENKUlvE_clEv"(ptr dead_on_unwind writable sret(%struct.Item) align 4 %second, ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
          to label %invoke.cont7 unwind label %lpad6

invoke.cont7:                                     ; preds = %cond.end
  %call9 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %local) #3
  ret void

lpad:                                             ; preds = %cond.false, %cond.true
  %0 = landingpad { ptr, i32 }
          cleanup
  %1 = extractvalue { ptr, i32 } %0, 0
  store ptr %1, ptr %exn.slot, align 8
  %2 = extractvalue { ptr, i32 } %0, 1
  store i32 %2, ptr %ehselector.slot, align 4
  br label %ehcleanup

lpad6:                                            ; preds = %cond.end
  %3 = landingpad { ptr, i32 }
          cleanup
  %4 = extractvalue { ptr, i32 } %3, 0
  store ptr %4, ptr %exn.slot, align 8
  %5 = extractvalue { ptr, i32 } %3, 1
  store i32 %5, ptr %ehselector.slot, align 4
  %call8 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %first) #3
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad6, %lpad
  %call10 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %local) #3
  br label %eh.resume

eh.resume:                                        ; preds = %ehcleanup
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val11 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val11
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN7GlobalsD1Ev(ptr noundef nonnull returned align 4 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7GlobalsD2Ev(ptr noundef nonnull align 4 dead_on_return(8) dereferenceable(8) %this1) #3
  ret ptr %this1
}

; Function Attrs: nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) #3

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_var_init.1() #1 section "__TEXT,__StaticInit,regular,pure_instructions" personality ptr @__gxx_personality_v0 {
entry:
  %arrayinit.endOfInit = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr @pair, ptr %arrayinit.endOfInit, align 8
  %call = invoke noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) @pair, i32 noundef 6)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  store ptr getelementptr inbounds nuw (i8, ptr @pair, i64 4), ptr %arrayinit.endOfInit, align 8
  %call2 = invoke noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) getelementptr inbounds nuw (i8, ptr @pair, i64 4), i32 noundef 7)
          to label %invoke.cont1 unwind label %lpad

invoke.cont1:                                     ; preds = %invoke.cont
  %0 = call i32 @__cxa_atexit(ptr @__cxx_global_array_dtor, ptr null, ptr @__dso_handle) #3
  ret void

lpad:                                             ; preds = %invoke.cont, %entry
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  store ptr %2, ptr %exn.slot, align 8
  %3 = extractvalue { ptr, i32 } %1, 1
  store i32 %3, ptr %ehselector.slot, align 4
  %4 = load ptr, ptr %arrayinit.endOfInit, align 8
  %arraydestroy.isempty = icmp eq ptr @pair, %4
  br i1 %arraydestroy.isempty, label %arraydestroy.done4, label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %lpad
  %arraydestroy.elementPast = phi ptr [ %4, %lpad ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Item, ptr %arraydestroy.elementPast, i64 -1
  %call3 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #3
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, @pair
  br i1 %arraydestroy.done, label %arraydestroy.done4, label %arraydestroy.body

arraydestroy.done4:                               ; preds = %arraydestroy.body, %lpad
  br label %eh.resume

eh.resume:                                        ; preds = %arraydestroy.done4
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val5 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val5
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %value) unnamed_addr #2 {
entry:
  %this.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr %value.addr, align 4
  %call = call noundef ptr @_ZN4ItemC2Ei(ptr noundef nonnull align 4 dereferenceable(4) %this1, i32 noundef %0)
  ret ptr %this1
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #3
  ret ptr %this1
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_array_dtor(ptr noundef %0) #1 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  %.addr = alloca ptr, align 8
  store ptr %0, ptr %.addr, align 8
  br label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %entry
  %arraydestroy.elementPast = phi ptr [ getelementptr inbounds nuw (i8, ptr @pair, i64 8), %entry ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Item, ptr %arraydestroy.elementPast, i64 -1
  %call = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #3
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, @pair
  br i1 %arraydestroy.done, label %arraydestroy.done1, label %arraydestroy.body

arraydestroy.done1:                               ; preds = %arraydestroy.body
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define internal void @"_ZZNK3$_0clEvENKUlvE_clEv"(ptr dead_on_unwind noalias writable sret(%struct.Item) align 4 %agg.result, ptr noundef nonnull align 1 dereferenceable(1) %this) #2 {
entry:
  %result.ptr = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %ref.tmp = alloca %struct.Item, align 4
  store ptr %agg.result, ptr %result.ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp, i32 noundef 4)
  call void @_Z7ObserveRK4Item(ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp)
  %call2 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp) #3
  %call3 = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %agg.result, i32 noundef 5)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN7GlobalsD2Ev(ptr noundef nonnull returned align 4 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %second = getelementptr inbounds nuw %struct.Globals, ptr %this1, i32 0, i32 1
  %call = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %second) #3
  %first = getelementptr inbounds nuw %struct.Globals, ptr %this1, i32 0, i32 0
  %call2 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %first) #3
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC2Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %value) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %value2 = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value2, align 4
  %1 = load i32, ptr %value.addr, align 4
  call void @_Z4Marki(i32 noundef %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  %0 = load i32, ptr %value, align 4
  %sub = sub nsw i32 0, %0
  call void @_Z4Marki(i32 noundef %sub)
  ret ptr %this1
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @_GLOBAL__sub_I_global_lifetimes.cpp() #1 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { noinline ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
