; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names temporary_lifetimes.cpp -o -
; ModuleID = 'temporary_lifetimes.cpp'
source_filename = "temporary_lifetimes.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Token = type { i8 }
%class.anon = type { ptr }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z5CheckRK5Token(ptr noundef nonnull align 1 dereferenceable(1) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  ret i1 false
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4Nextv() #0 {
entry:
  ret i32 7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z3Usebi(i1 noundef zeroext %test, i32 noundef %next) #0 {
entry:
  %test.addr = alloca i8, align 1
  %next.addr = alloca i32, align 4
  %storedv = zext i1 %test to i8
  store i8 %storedv, ptr %test.addr, align 1
  store i32 %next, ptr %next.addr, align 4
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z5Shortb(i1 noundef zeroext %flag) #1 {
entry:
  %flag.addr = alloca i8, align 1
  %ref.tmp = alloca %struct.Token, align 1
  %cleanup.cond = alloca i1, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  store i1 false, ptr %cleanup.cond, align 1
  br i1 %loadedv, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %entry
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  store i1 true, ptr %cleanup.cond, align 1
  %call1 = call noundef zeroext i1 @_Z5CheckRK5Token(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %1 = phi i1 [ false, %entry ], [ %call1, %land.rhs ]
  %call2 = call noundef i32 @_Z4Nextv()
  call void @_Z3Usebi(i1 noundef zeroext %1, i32 noundef %call2)
  %cleanup.is_active = load i1, ptr %cleanup.cond, align 1
  br i1 %cleanup.is_active, label %cleanup.action, label %cleanup.done

cleanup.action:                                   ; preds = %land.end
  %call3 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #2
  br label %cleanup.done

cleanup.done:                                     ; preds = %cleanup.action, %land.end
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5TokenC2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5TokenD2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6RepeatRbb(ptr noundef nonnull align 1 dereferenceable(1) %flag, i1 noundef zeroext %other) #1 {
entry:
  %flag.addr = alloca ptr, align 8
  %other.addr = alloca i8, align 1
  %ref.tmp = alloca %struct.Token, align 1
  %cleanup.cond = alloca i1, align 1
  store ptr %flag, ptr %flag.addr, align 8
  %storedv = zext i1 %other to i8
  store i8 %storedv, ptr %other.addr, align 1
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load ptr, ptr %flag.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %loadedv = icmp ne i8 %1, 0
  store i1 false, ptr %cleanup.cond, align 1
  br i1 %loadedv, label %land.rhs, label %land.end4

land.rhs:                                         ; preds = %while.cond
  %2 = load i8, ptr %other.addr, align 1
  %loadedv1 = icmp ne i8 %2, 0
  br i1 %loadedv1, label %land.rhs2, label %land.end

land.rhs2:                                        ; preds = %land.rhs
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  store i1 true, ptr %cleanup.cond, align 1
  %call3 = call noundef zeroext i1 @_Z5CheckRK5Token(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  br label %land.end

land.end:                                         ; preds = %land.rhs2, %land.rhs
  %3 = phi i1 [ false, %land.rhs ], [ %call3, %land.rhs2 ]
  br label %land.end4

land.end4:                                        ; preds = %land.end, %while.cond
  %4 = phi i1 [ false, %while.cond ], [ %3, %land.end ]
  %cleanup.is_active = load i1, ptr %cleanup.cond, align 1
  br i1 %cleanup.is_active, label %cleanup.action, label %cleanup.done

cleanup.action:                                   ; preds = %land.end4
  %call5 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #2
  br label %cleanup.done

cleanup.done:                                     ; preds = %cleanup.action, %land.end4
  br i1 %4, label %while.body, label %while.end

while.body:                                       ; preds = %cleanup.done
  %5 = load ptr, ptr %flag.addr, align 8, !nonnull !5
  store i8 0, ptr %5, align 1
  br label %while.cond, !llvm.loop !6

while.end:                                        ; preds = %cleanup.done
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z6ChangeRb(ptr noundef nonnull align 1 dereferenceable(1) %flag) #0 {
entry:
  %flag.addr = alloca ptr, align 8
  store ptr %flag, ptr %flag.addr, align 8
  %0 = load ptr, ptr %flag.addr, align 8, !nonnull !5
  store i8 0, ptr %0, align 1
  ret i32 7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6Choiceb(i1 noundef zeroext %flag) #1 personality ptr @__gxx_personality_v0 {
entry:
  %flag.addr = alloca i8, align 1
  %use = alloca %class.anon, align 8
  %ref.tmp = alloca %struct.Token, align 1
  %cleanup.cond = alloca i1, align 1
  %ref.tmp2 = alloca %struct.Token, align 1
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %cleanup.cond4 = alloca i1, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = getelementptr inbounds nuw %class.anon, ptr %use, i32 0, i32 0
  store ptr %flag.addr, ptr %0, align 8
  %1 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  store i1 false, ptr %cleanup.cond, align 1
  store i1 false, ptr %cleanup.cond4, align 1
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  store i1 true, ptr %cleanup.cond, align 1
  %call1 = call noundef zeroext i1 @_Z5CheckRK5Token(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %call3 = invoke noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp2)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %cond.false
  store i1 true, ptr %cleanup.cond4, align 1
  %call5 = call noundef zeroext i1 @_Z5CheckRK5Token(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp2)
  br label %cond.end

cond.end:                                         ; preds = %invoke.cont, %cond.true
  %cond = phi i1 [ %call1, %cond.true ], [ %call5, %invoke.cont ]
  invoke void @"_ZZ6ChoicebENK3$_0clEb"(ptr noundef nonnull align 8 dereferenceable(8) %use, i1 noundef zeroext %cond)
          to label %invoke.cont7 unwind label %lpad6

invoke.cont7:                                     ; preds = %cond.end
  %cleanup.is_active = load i1, ptr %cleanup.cond4, align 1
  br i1 %cleanup.is_active, label %cleanup.action, label %cleanup.done

cleanup.action:                                   ; preds = %invoke.cont7
  %call8 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp2) #2
  br label %cleanup.done

cleanup.done:                                     ; preds = %cleanup.action, %invoke.cont7
  %cleanup.is_active13 = load i1, ptr %cleanup.cond, align 1
  br i1 %cleanup.is_active13, label %cleanup.action14, label %cleanup.done16

cleanup.action14:                                 ; preds = %cleanup.done
  %call15 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #2
  br label %cleanup.done16

cleanup.done16:                                   ; preds = %cleanup.action14, %cleanup.done
  ret void

lpad:                                             ; preds = %cond.false
  %2 = landingpad { ptr, i32 }
          cleanup
  %3 = extractvalue { ptr, i32 } %2, 0
  store ptr %3, ptr %exn.slot, align 8
  %4 = extractvalue { ptr, i32 } %2, 1
  store i32 %4, ptr %ehselector.slot, align 4
  br label %ehcleanup

lpad6:                                            ; preds = %cond.end
  %5 = landingpad { ptr, i32 }
          cleanup
  %6 = extractvalue { ptr, i32 } %5, 0
  store ptr %6, ptr %exn.slot, align 8
  %7 = extractvalue { ptr, i32 } %5, 1
  store i32 %7, ptr %ehselector.slot, align 4
  %cleanup.is_active9 = load i1, ptr %cleanup.cond4, align 1
  br i1 %cleanup.is_active9, label %cleanup.action10, label %cleanup.done12

cleanup.action10:                                 ; preds = %lpad6
  %call11 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp2) #2
  br label %cleanup.done12

cleanup.done12:                                   ; preds = %cleanup.action10, %lpad6
  br label %ehcleanup

ehcleanup:                                        ; preds = %cleanup.done12, %lpad
  %cleanup.is_active17 = load i1, ptr %cleanup.cond, align 1
  br i1 %cleanup.is_active17, label %cleanup.action18, label %cleanup.done20

cleanup.action18:                                 ; preds = %ehcleanup
  %call19 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #2
  br label %cleanup.done20

cleanup.done20:                                   ; preds = %cleanup.action18, %ehcleanup
  br label %eh.resume

eh.resume:                                        ; preds = %cleanup.done20
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val21 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val21
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define internal void @"_ZZ6ChoicebENK3$_0clEb"(ptr noundef nonnull align 8 dereferenceable(8) %this, i1 noundef zeroext %test) #0 {
entry:
  %this.addr = alloca ptr, align 8
  %test.addr = alloca i8, align 1
  store ptr %this, ptr %this.addr, align 8
  %storedv = zext i1 %test to i8
  store i8 %storedv, ptr %test.addr, align 1
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i8, ptr %test.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %1 = getelementptr inbounds nuw %class.anon, ptr %this1, i32 0, i32 0
  %2 = load ptr, ptr %1, align 8, !nonnull !5
  %call = call noundef i32 @_Z6ChangeRb(ptr noundef nonnull align 1 dereferenceable(1) %2)
  call void @_Z3Usebi(i1 noundef zeroext %loadedv, i32 noundef %call)
  ret void
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenD2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
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
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
