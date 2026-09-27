; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names local_lifetimes.cpp -o -
; ModuleID = 'local_lifetimes.cpp'
source_filename = "local_lifetimes.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Token = type { i8 }

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z8Deferredb(i1 noundef zeroext %flag) #0 personality ptr @__gxx_personality_v0 {
entry:
  %flag.addr = alloca i8, align 1
  %storage = alloca [1 x i8], align 1
  %outer = alloca ptr, align 8
  %inner = alloca %struct.Token, align 1
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %arraydecay = getelementptr inbounds [1 x i8], ptr %storage, i64 0, i64 0
  store ptr %arraydecay, ptr %outer, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %inner)
  %1 = load ptr, ptr %outer, align 8
  %call1 = invoke noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %if.then
  %call2 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %inner) #2
  br label %if.end

lpad:                                             ; preds = %if.then
  %2 = landingpad { ptr, i32 }
          cleanup
  %3 = extractvalue { ptr, i32 } %2, 0
  store ptr %3, ptr %exn.slot, align 8
  %4 = extractvalue { ptr, i32 } %2, 1
  store i32 %4, ptr %ehselector.slot, align 4
  %call3 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %inner) #2
  br label %eh.resume

if.else:                                          ; preds = %entry
  %5 = load ptr, ptr %outer, align 8
  %call4 = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %5)
  br label %if.end

if.end:                                           ; preds = %if.else, %invoke.cont
  %6 = load ptr, ptr %outer, align 8
  %call5 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %6) #2
  ret void

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val6 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val6
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5TokenC2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1)
  ret ptr %this1
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5TokenD2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z5Earlyb(i1 noundef zeroext %flag) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %outer = alloca %struct.Token, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %outer)
  %call1 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %outer) #2
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4Loopbb(i1 noundef zeroext %flag, i1 noundef zeroext %stop) #0 personality ptr @__gxx_personality_v0 {
entry:
  %flag.addr = alloca i8, align 1
  %stop.addr = alloca i8, align 1
  %outer = alloca %struct.Token, align 1
  %inner = alloca %struct.Token, align 1
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %stop to i8
  store i8 %storedv1, ptr %stop.addr, align 1
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %outer)
  br label %while.cond

while.cond:                                       ; preds = %cleanup, %entry
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %call2 = invoke noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %inner)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %while.body
  %1 = load i8, ptr %stop.addr, align 1
  %loadedv3 = icmp ne i8 %1, 0
  br i1 %loadedv3, label %if.then, label %if.end

if.then:                                          ; preds = %invoke.cont
  store i32 3, ptr %cleanup.dest.slot, align 4
  br label %cleanup

lpad:                                             ; preds = %while.body
  %2 = landingpad { ptr, i32 }
          cleanup
  %3 = extractvalue { ptr, i32 } %2, 0
  store ptr %3, ptr %exn.slot, align 8
  %4 = extractvalue { ptr, i32 } %2, 1
  store i32 %4, ptr %ehselector.slot, align 4
  %call6 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %outer) #2
  br label %eh.resume

if.end:                                           ; preds = %invoke.cont
  store i32 2, ptr %cleanup.dest.slot, align 4
  br label %cleanup, !llvm.loop !5

cleanup:                                          ; preds = %if.end, %if.then
  %call4 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %inner) #2
  %cleanup.dest = load i32, ptr %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %unreachable [
    i32 3, label %while.end
    i32 2, label %while.cond
  ]

while.end:                                        ; preds = %cleanup, %while.cond
  %call5 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %outer) #2
  ret void

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val7 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val7

unreachable:                                      ; preds = %cleanup
  unreachable
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenD2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.mustprogress"}
