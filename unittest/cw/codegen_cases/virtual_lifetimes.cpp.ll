; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti virtual_lifetimes.cpp -o -
; ModuleID = 'virtual_lifetimes.cpp'
source_filename = "virtual_lifetimes.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Derived = type <{ %struct.Base, %struct.Watch, i32, [4 x i8] }>
%struct.Base = type { ptr }
%struct.Watch = type { ptr }

@trace = global i64 0, align 8
@_ZTV4Base = unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr @_ZNK4Base4ReadEv] }, align 8
@_ZTV7Derived = unnamed_addr constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr @_ZNK7Derived4ReadEv] }, align 8
@global = global %struct.Derived zeroinitializer, align 8
@__dso_handle = external hidden global i8
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_virtual_lifetimes.cpp, ptr null }]

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK4Base4ReadEv(ptr noundef nonnull align 8 dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret i32 1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6RecordRK4Base(ptr noundef nonnull align 8 dereferenceable(8) %object) #1 {
entry:
  %object.addr = alloca ptr, align 8
  store ptr %object, ptr %object.addr, align 8
  %0 = load i64, ptr @trace, align 8
  %mul = mul nsw i64 %0, 10
  %1 = load ptr, ptr %object.addr, align 8, !nonnull !5, !align !6
  %vtable = load ptr, ptr %1, align 8
  %vfn = getelementptr inbounds ptr, ptr %vtable, i64 0
  %2 = load ptr, ptr %vfn, align 8
  %call = call noundef i32 %2(ptr noundef nonnull align 8 dereferenceable(8) %1)
  %conv = sext i32 %call to i64
  %add = add nsw i64 %mul, %conv
  store i64 %add, ptr @trace, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4BaseC2Ev(ptr noundef nonnull returned align 8 dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @_ZTV4Base, i32 0, i32 0, i32 2), ptr %this1, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4BaseC1Ev(ptr noundef nonnull returned align 8 dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4BaseC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4BaseD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @_ZTV4Base, i32 0, i32 0, i32 2), ptr %this1, align 8
  invoke void @_Z6RecordRK4Base(ptr noundef nonnull align 8 dereferenceable(8) %this1)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %entry
  ret ptr %this1

terminate.lpad:                                   ; preds = %entry
  %0 = landingpad { ptr, i32 }
          catch ptr null
  %1 = extractvalue { ptr, i32 } %0, 0
  call void @__clang_call_terminate(ptr %1) #5
  unreachable
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: noinline noreturn nounwind ssp uwtable(sync)
define linkonce_odr hidden void @__clang_call_terminate(ptr noundef %0) #2 {
  %2 = call ptr @__cxa_begin_catch(ptr %0) #4
  call void @_ZSt9terminatev() #5
  unreachable
}

declare ptr @__cxa_begin_catch(ptr)

declare void @_ZSt9terminatev()

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN4BaseD1Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4BaseD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN5WatchC2EPK4Base(ptr noundef nonnull returned align 8 dereferenceable(8) %this, ptr noundef %input) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %input, ptr %input.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.Watch, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %input.addr, align 8
  store ptr %0, ptr %target, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN5WatchC1EPK4Base(ptr noundef nonnull returned align 8 dereferenceable(8) %this, ptr noundef %input) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %input, ptr %input.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %input.addr, align 8
  %call = call noundef ptr @_ZN5WatchC2EPK4Base(ptr noundef nonnull align 8 dereferenceable(8) %this1, ptr noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN5WatchD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.Watch, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %target, align 8
  invoke void @_Z6RecordRK4Base(ptr noundef nonnull align 8 dereferenceable(8) %0)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %entry
  ret ptr %this1

terminate.lpad:                                   ; preds = %entry
  %1 = landingpad { ptr, i32 }
          catch ptr null
  %2 = extractvalue { ptr, i32 } %1, 0
  call void @__clang_call_terminate(ptr %2) #5
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN5WatchD1Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5WatchD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8CompleteRK5Watch(ptr noundef nonnull align 8 dereferenceable(8) %0) #0 {
entry:
  %.addr = alloca ptr, align 8
  store ptr %0, ptr %.addr, align 8
  ret i32 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZNK7Derived4ReadEv(ptr noundef nonnull align 8 dereferenceable(20) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret i32 2
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedC2Eb(ptr noundef nonnull returned align 8 dereferenceable(20) %this, i1 noundef zeroext %flag) unnamed_addr #1 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %ref.tmp = alloca %struct.Watch, align 8
  %local = alloca %struct.Watch, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4BaseC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1)
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @_ZTV7Derived, i32 0, i32 0, i32 2), ptr %this1, align 8
  %watch = getelementptr inbounds nuw %struct.Derived, ptr %this1, i32 0, i32 1
  %call2 = call noundef ptr @_ZN5WatchC1EPK4Base(ptr noundef nonnull align 8 dereferenceable(8) %watch, ptr noundef %this1)
  %value = getelementptr inbounds nuw %struct.Derived, ptr %this1, i32 0, i32 2
  %call3 = call noundef ptr @_ZN5WatchC1EPK4Base(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp, ptr noundef %this1)
  %call4 = call noundef i32 @_Z8CompleteRK5Watch(ptr noundef nonnull align 8 dereferenceable(8) %ref.tmp)
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %1 = zext i1 %loadedv to i64
  %cond = select i1 %loadedv, i32 0, i32 1
  %add = add nsw i32 %call4, %cond
  %call5 = call noundef ptr @_ZN5WatchD1Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %ref.tmp) #4
  store i32 %add, ptr %value, align 8
  %call6 = call noundef ptr @_ZN5WatchC1EPK4Base(ptr noundef nonnull align 8 dereferenceable(8) %local, ptr noundef %this1)
  invoke void @_Z6RecordRK4Base(ptr noundef nonnull align 8 dereferenceable(8) %this1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %call7 = call noundef ptr @_ZN5WatchD1Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %local) #4
  ret ptr %this1

lpad:                                             ; preds = %entry
  %2 = landingpad { ptr, i32 }
          cleanup
  %3 = extractvalue { ptr, i32 } %2, 0
  store ptr %3, ptr %exn.slot, align 8
  %4 = extractvalue { ptr, i32 } %2, 1
  store i32 %4, ptr %ehselector.slot, align 4
  %call8 = call noundef ptr @_ZN5WatchD1Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %local) #4
  %call9 = call noundef ptr @_ZN5WatchD1Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %watch) #4
  %call10 = call noundef ptr @_ZN4BaseD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val11 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val11
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedC1Eb(ptr noundef nonnull returned align 8 dereferenceable(20) %this, i1 noundef zeroext %flag) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  store ptr %this, ptr %this.addr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef ptr @_ZN7DerivedC2Eb(ptr noundef nonnull align 8 dereferenceable(20) %this1, i1 noundef zeroext %loadedv)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedC2Ev(ptr noundef nonnull returned align 8 dereferenceable(20) %this) unnamed_addr #1 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7DerivedC2Eb(ptr noundef nonnull align 8 dereferenceable(20) %this1, i1 noundef zeroext true)
  invoke void @_Z6RecordRK4Base(ptr noundef nonnull align 8 dereferenceable(8) %this1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  ret ptr %this1

lpad:                                             ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  %1 = extractvalue { ptr, i32 } %0, 0
  store ptr %1, ptr %exn.slot, align 8
  %2 = extractvalue { ptr, i32 } %0, 1
  store i32 %2, ptr %ehselector.slot, align 4
  %call2 = call noundef ptr @_ZN7DerivedD2Ev(ptr noundef nonnull align 8 dead_on_return(20) dereferenceable(20) %this1) #4
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val3 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedD2Ev(ptr noundef nonnull returned align 8 dead_on_return(20) dereferenceable(20) %this) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %local = alloca %struct.Watch, align 8
  %cleanup.dest.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @_ZTV7Derived, i32 0, i32 0, i32 2), ptr %this1, align 8
  %call = call noundef ptr @_ZN5WatchC1EPK4Base(ptr noundef nonnull align 8 dereferenceable(8) %local, ptr noundef %this1)
  invoke void @_Z6RecordRK4Base(ptr noundef nonnull align 8 dereferenceable(8) %this1)
          to label %invoke.cont unwind label %terminate.lpad

invoke.cont:                                      ; preds = %entry
  %value = getelementptr inbounds nuw %struct.Derived, ptr %this1, i32 0, i32 2
  %0 = load i32, ptr %value, align 8
  %cmp = icmp eq i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %invoke.cont
  store i32 1, ptr %cleanup.dest.slot, align 4
  br label %cleanup

if.end:                                           ; preds = %invoke.cont
  store i32 0, ptr %cleanup.dest.slot, align 4
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  %call2 = call noundef ptr @_ZN5WatchD1Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %local) #4
  %cleanup.dest = load i32, ptr %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %cleanup3 [
    i32 0, label %cleanup.cont
  ]

cleanup.cont:                                     ; preds = %cleanup
  store i32 0, ptr %cleanup.dest.slot, align 4
  br label %cleanup3

cleanup3:                                         ; preds = %cleanup.cont, %cleanup
  %watch = getelementptr inbounds nuw %struct.Derived, ptr %this1, i32 0, i32 1
  %call4 = call noundef ptr @_ZN5WatchD1Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %watch) #4
  %call6 = call noundef ptr @_ZN4BaseD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #4
  %cleanup.dest7 = load i32, ptr %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest7, label %unreachable [
    i32 0, label %cleanup.cont8
    i32 1, label %cleanup.cont8
  ]

cleanup.cont8:                                    ; preds = %cleanup3, %cleanup3
  %1 = load ptr, ptr %retval, align 8
  ret ptr %1

terminate.lpad:                                   ; preds = %entry
  %2 = landingpad { ptr, i32 }
          catch ptr null
  %3 = extractvalue { ptr, i32 } %2, 0
  call void @__clang_call_terminate(ptr %3) #5
  unreachable

unreachable:                                      ; preds = %cleanup3
  unreachable
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedC1Ev(ptr noundef nonnull returned align 8 dereferenceable(20) %this) unnamed_addr #1 personality ptr @__gxx_personality_v0 {
entry:
  %this.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7DerivedC1Eb(ptr noundef nonnull align 8 dereferenceable(20) %this1, i1 noundef zeroext true)
  invoke void @_Z6RecordRK4Base(ptr noundef nonnull align 8 dereferenceable(8) %this1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  ret ptr %this1

lpad:                                             ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  %1 = extractvalue { ptr, i32 } %0, 0
  store ptr %1, ptr %exn.slot, align 8
  %2 = extractvalue { ptr, i32 } %0, 1
  store i32 %2, ptr %ehselector.slot, align 4
  %call2 = call noundef ptr @_ZN7DerivedD1Ev(ptr noundef nonnull align 8 dead_on_return(20) dereferenceable(20) %this1) #4
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val3 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_ZN7DerivedD1Ev(ptr noundef nonnull returned align 8 dead_on_return(20) dereferenceable(20) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7DerivedD2Ev(ptr noundef nonnull align 8 dead_on_return(20) dereferenceable(20) %this1) #4
  ret ptr %this1
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_var_init() #3 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  %call = call noundef ptr @_ZN7DerivedC1Eb(ptr noundef nonnull align 8 dereferenceable(20) @global, i1 noundef zeroext true)
  %0 = call i32 @__cxa_atexit(ptr @_ZN7DerivedD1Ev, ptr @global, ptr @__dso_handle) #4
  ret void
}

; Function Attrs: nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) #4

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z9ReadTracev() #0 {
entry:
  %0 = load i64, ptr @trace, align 8
  ret i64 %0
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z5Entryb(i1 noundef zeroext %flag) #1 {
entry:
  %flag.addr = alloca i8, align 1
  %value = alloca %struct.Derived, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i64 0, ptr @trace, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef ptr @_ZN7DerivedC1Eb(ptr noundef nonnull align 8 dereferenceable(20) %value, i1 noundef zeroext %loadedv)
  %call1 = call noundef ptr @_ZN7DerivedD1Ev(ptr noundef nonnull align 8 dead_on_return(20) dereferenceable(20) %value) #4
  %1 = load i64, ptr @trace, align 8
  ret i64 %1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z8Delegatev() #1 {
entry:
  %value = alloca %struct.Derived, align 8
  store i64 0, ptr @trace, align 8
  %call = call noundef ptr @_ZN7DerivedC1Ev(ptr noundef nonnull align 8 dereferenceable(20) %value)
  %call1 = call noundef ptr @_ZN7DerivedD1Ev(ptr noundef nonnull align 8 dead_on_return(20) dereferenceable(20) %value) #4
  %0 = load i64, ptr @trace, align 8
  ret i64 %0
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @_GLOBAL__sub_I_virtual_lifetimes.cpp() #3 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  call void @__cxx_global_var_init()
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { noinline noreturn nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { noinline ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
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
