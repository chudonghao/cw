; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti virtual_pointers.cpp -o -
; ModuleID = 'virtual_pointers.cpp'
source_filename = "virtual_pointers.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Item = type <{ ptr, i32, [4 x i8] }>

@_ZTV4Item = unnamed_addr constant { [4 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @_ZNK4Item5FirstEv, ptr @_ZNK4Item6SecondEv] }, align 8

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK4Item5FirstEv(ptr noundef nonnull align 8 dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 1
  %0 = load i32, ptr %value, align 8
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK4Item6SecondEv(ptr noundef nonnull align 8 dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 1
  %0 = load i32, ptr %value, align 8
  %add = add nsw i32 %0, 10
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4ItemC2Ei(ptr noundef nonnull returned align 8 dereferenceable(12) %this, i32 noundef %input) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr] }, ptr @_ZTV4Item, i32 0, i32 0, i32 2), ptr %this1, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 1
  %0 = load i32, ptr %input.addr, align 4
  store i32 %0, ptr %value, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull returned align 8 dereferenceable(12) %this, i32 noundef %input) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr %input.addr, align 4
  %call = call noundef ptr @_ZN4ItemC2Ei(ptr noundef nonnull align 8 dereferenceable(12) %this1, i32 noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z8IdentityM4ItemKFivE([2 x i64] %pointer.coerce) #0 {
entry:
  %retval = alloca { i64, i64 }, align 8
  %pointer = alloca { i64, i64 }, align 8
  %pointer.addr = alloca { i64, i64 }, align 8
  store [2 x i64] %pointer.coerce, ptr %pointer, align 8
  %pointer1 = load { i64, i64 }, ptr %pointer, align 8
  store { i64, i64 } %pointer1, ptr %pointer.addr, align 8
  %0 = load { i64, i64 }, ptr %pointer.addr, align 8
  store { i64, i64 } %0, ptr %retval, align 8
  %1 = load [2 x i64], ptr %retval, align 8
  ret [2 x i64] %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(12) ptr @_Z7ReplaceRM4ItemKFivERKS_(ptr noundef nonnull align 8 dereferenceable(16) %pointer, ptr noundef nonnull align 8 dereferenceable(12) %item) #0 {
entry:
  %pointer.addr = alloca ptr, align 8
  %item.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %item, ptr %item.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8, !nonnull !5, !align !6
  store { i64, i64 } { i64 8, i64 1 }, ptr %0, align 8
  %1 = load ptr, ptr %item.addr, align 8, !nonnull !5, !align !6
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11DirectFirstRK4Item(ptr noundef nonnull align 8 dereferenceable(12) %item) #0 {
entry:
  %item.addr = alloca ptr, align 8
  store ptr %item, ptr %item.addr, align 8
  %0 = load ptr, ptr %item.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZNK4Item5FirstEv(ptr noundef nonnull align 8 dereferenceable(12) %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z6InvokeRK4Item(ptr noundef nonnull align 8 dereferenceable(12) %item) #1 {
entry:
  %item.addr = alloca ptr, align 8
  %pointer = alloca { i64, i64 }, align 8
  %coerce = alloca { i64, i64 }, align 8
  %coerce1 = alloca { i64, i64 }, align 8
  %copied = alloca { i64, i64 }, align 8
  %direct = alloca ptr, align 8
  %saved = alloca { i64, i64 }, align 8
  %result = alloca i32, align 4
  store ptr %item, ptr %item.addr, align 8
  store { i64, i64 } { i64 0, i64 1 }, ptr %coerce, align 8
  %0 = load [2 x i64], ptr %coerce, align 8
  %call = call [2 x i64] @_Z8IdentityM4ItemKFivE([2 x i64] %0)
  store [2 x i64] %call, ptr %coerce1, align 8
  %1 = load { i64, i64 }, ptr %coerce1, align 8
  store { i64, i64 } %1, ptr %pointer, align 8
  %2 = load { i64, i64 }, ptr %pointer, align 8
  store { i64, i64 } %2, ptr %copied, align 8
  store ptr @_Z11DirectFirstRK4Item, ptr %direct, align 8
  %3 = load { i64, i64 }, ptr %pointer, align 8
  store { i64, i64 } %3, ptr %saved, align 8
  %4 = load ptr, ptr %item.addr, align 8, !nonnull !5, !align !6
  %call2 = call noundef nonnull align 8 dereferenceable(12) ptr @_Z7ReplaceRM4ItemKFivERKS_(ptr noundef nonnull align 8 dereferenceable(16) %pointer, ptr noundef nonnull align 8 dereferenceable(12) %4)
  %5 = load { i64, i64 }, ptr %saved, align 8
  %memptr.adj = extractvalue { i64, i64 } %5, 1
  %memptr.adj.shifted = ashr i64 %memptr.adj, 1
  %6 = getelementptr inbounds i8, ptr %call2, i64 %memptr.adj.shifted
  %memptr.ptr = extractvalue { i64, i64 } %5, 0
  %7 = and i64 %memptr.adj, 1
  %memptr.isvirtual = icmp ne i64 %7, 0
  br i1 %memptr.isvirtual, label %memptr.virtual, label %memptr.nonvirtual

memptr.virtual:                                   ; preds = %entry
  %vtable = load ptr, ptr %6, align 8
  %8 = trunc i64 %memptr.ptr to i32
  %9 = zext i32 %8 to i64
  %10 = getelementptr i8, ptr %vtable, i64 %9, !nosanitize !5
  %memptr.virtualfn = load ptr, ptr %10, align 8, !nosanitize !5
  br label %memptr.end

memptr.nonvirtual:                                ; preds = %entry
  %memptr.nonvirtualfn = inttoptr i64 %memptr.ptr to ptr
  br label %memptr.end

memptr.end:                                       ; preds = %memptr.nonvirtual, %memptr.virtual
  %11 = phi ptr [ %memptr.virtualfn, %memptr.virtual ], [ %memptr.nonvirtualfn, %memptr.nonvirtual ]
  %call3 = call noundef i32 %11(ptr noundef nonnull align 8 dereferenceable(12) %6)
  store i32 %call3, ptr %result, align 4
  %12 = load i32, ptr %result, align 4
  %13 = load ptr, ptr %item.addr, align 8, !nonnull !5, !align !6
  %14 = load { i64, i64 }, ptr %pointer, align 8
  %memptr.adj4 = extractvalue { i64, i64 } %14, 1
  %memptr.adj.shifted5 = ashr i64 %memptr.adj4, 1
  %15 = getelementptr inbounds i8, ptr %13, i64 %memptr.adj.shifted5
  %memptr.ptr6 = extractvalue { i64, i64 } %14, 0
  %16 = and i64 %memptr.adj4, 1
  %memptr.isvirtual7 = icmp ne i64 %16, 0
  br i1 %memptr.isvirtual7, label %memptr.virtual8, label %memptr.nonvirtual11

memptr.virtual8:                                  ; preds = %memptr.end
  %vtable9 = load ptr, ptr %15, align 8
  %17 = trunc i64 %memptr.ptr6 to i32
  %18 = zext i32 %17 to i64
  %19 = getelementptr i8, ptr %vtable9, i64 %18, !nosanitize !5
  %memptr.virtualfn10 = load ptr, ptr %19, align 8, !nosanitize !5
  br label %memptr.end13

memptr.nonvirtual11:                              ; preds = %memptr.end
  %memptr.nonvirtualfn12 = inttoptr i64 %memptr.ptr6 to ptr
  br label %memptr.end13

memptr.end13:                                     ; preds = %memptr.nonvirtual11, %memptr.virtual8
  %20 = phi ptr [ %memptr.virtualfn10, %memptr.virtual8 ], [ %memptr.nonvirtualfn12, %memptr.nonvirtual11 ]
  %call14 = call noundef i32 %20(ptr noundef nonnull align 8 dereferenceable(12) %15)
  %add = add nsw i32 %12, %call14
  %21 = load ptr, ptr %item.addr, align 8, !nonnull !5, !align !6
  %22 = load { i64, i64 }, ptr %copied, align 8
  %memptr.adj15 = extractvalue { i64, i64 } %22, 1
  %memptr.adj.shifted16 = ashr i64 %memptr.adj15, 1
  %23 = getelementptr inbounds i8, ptr %21, i64 %memptr.adj.shifted16
  %memptr.ptr17 = extractvalue { i64, i64 } %22, 0
  %24 = and i64 %memptr.adj15, 1
  %memptr.isvirtual18 = icmp ne i64 %24, 0
  br i1 %memptr.isvirtual18, label %memptr.virtual19, label %memptr.nonvirtual22

memptr.virtual19:                                 ; preds = %memptr.end13
  %vtable20 = load ptr, ptr %23, align 8
  %25 = trunc i64 %memptr.ptr17 to i32
  %26 = zext i32 %25 to i64
  %27 = getelementptr i8, ptr %vtable20, i64 %26, !nosanitize !5
  %memptr.virtualfn21 = load ptr, ptr %27, align 8, !nosanitize !5
  br label %memptr.end24

memptr.nonvirtual22:                              ; preds = %memptr.end13
  %memptr.nonvirtualfn23 = inttoptr i64 %memptr.ptr17 to ptr
  br label %memptr.end24

memptr.end24:                                     ; preds = %memptr.nonvirtual22, %memptr.virtual19
  %28 = phi ptr [ %memptr.virtualfn21, %memptr.virtual19 ], [ %memptr.nonvirtualfn23, %memptr.nonvirtual22 ]
  %call25 = call noundef i32 %28(ptr noundef nonnull align 8 dereferenceable(12) %23)
  %add26 = add nsw i32 %add, %call25
  %29 = load ptr, ptr %direct, align 8
  %30 = load ptr, ptr %item.addr, align 8, !nonnull !5, !align !6
  %call27 = call noundef i32 %29(ptr noundef nonnull align 8 dereferenceable(12) %30)
  %add28 = add nsw i32 %add26, %call27
  ret i32 %add28
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z5Entryv() #1 personality ptr @__gxx_personality_v0 {
entry:
  %first = alloca %struct.Item, align 8
  %second = alloca %struct.Item, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %call = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 8 dereferenceable(12) %first, i32 noundef 3)
  %call1 = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 8 dereferenceable(12) %second, i32 noundef 7)
  %call2 = invoke noundef i32 @_Z6InvokeRK4Item(ptr noundef nonnull align 8 dereferenceable(12) %first)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %call4 = invoke noundef i32 @_Z6InvokeRK4Item(ptr noundef nonnull align 8 dereferenceable(12) %second)
          to label %invoke.cont3 unwind label %lpad

invoke.cont3:                                     ; preds = %invoke.cont
  %add = add nsw i32 %call2, %call4
  %call5 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %second) #2
  %call7 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %first) #2
  ret i32 %add

lpad:                                             ; preds = %invoke.cont, %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  %1 = extractvalue { ptr, i32 } %0, 0
  store ptr %1, ptr %exn.slot, align 8
  %2 = extractvalue { ptr, i32 } %0, 1
  store i32 %2, ptr %ehselector.slot, align 4
  %call6 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %second) #2
  %call8 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %first) #2
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val9 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val9
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z5Emptyv() #0 {
entry:
  %pointer = alloca { i64, i64 }, align 8
  store { i64, i64 } zeroinitializer, ptr %pointer, align 8
  %0 = load { i64, i64 }, ptr %pointer, align 8
  %lhs.memptr.ptr = extractvalue { i64, i64 } %0, 0
  %cmp.ptr = icmp eq i64 %lhs.memptr.ptr, 0
  %cmp.ptr.null = icmp eq i64 %lhs.memptr.ptr, 0
  %lhs.memptr.adj = extractvalue { i64, i64 } %0, 1
  %cmp.adj = icmp eq i64 %lhs.memptr.adj, 0
  %or.adj = or i64 %lhs.memptr.adj, 0
  %1 = and i64 %or.adj, 1
  %cmp.or.adj = icmp eq i64 %1, 0
  %2 = and i1 %cmp.ptr.null, %cmp.or.adj
  %3 = or i1 %2, %cmp.adj
  %memptr.eq = and i1 %cmp.ptr, %3
  ret i1 %memptr.eq
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z7Presentv() #0 {
entry:
  %pointer = alloca { i64, i64 }, align 8
  store { i64, i64 } { i64 0, i64 1 }, ptr %pointer, align 8
  %0 = load { i64, i64 }, ptr %pointer, align 8
  %rhs.memptr.ptr = extractvalue { i64, i64 } %0, 0
  %cmp.ptr = icmp ne i64 0, %rhs.memptr.ptr
  %rhs.memptr.adj = extractvalue { i64, i64 } %0, 1
  %cmp.adj = icmp ne i64 0, %rhs.memptr.adj
  %or.adj = or i64 0, %rhs.memptr.adj
  %1 = and i64 %or.adj, 1
  %cmp.or.adj = icmp ne i64 %1, 0
  %2 = or i1 false, %cmp.or.adj
  %3 = and i1 %2, %cmp.adj
  %memptr.ne = or i1 %cmp.ptr, %3
  ret i1 %memptr.ne
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 8}
