; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names object_assignment.cpp -o -
; ModuleID = 'object_assignment.cpp'
source_filename = "object_assignment.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Value = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6TargetR5ValueS0_RKS_(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %token) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %token.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %token, ptr %token.addr, align 8
  %0 = load ptr, ptr %token.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  %2 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %number1 = getelementptr inbounds nuw %struct.Value, ptr %2, i32 0, i32 0
  store i32 %1, ptr %number1, align 4
  %3 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  ret ptr %3
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6SourceRK5Value(ptr dead_on_unwind noalias writable sret(%struct.Value) align 4 %agg.result, ptr noundef nonnull align 4 dereferenceable(4) %source) #1 {
entry:
  %result.ptr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %agg.result, ptr %result.ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  %call = call noundef ptr @_ZN5ValueC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %agg.result, i32 noundef %1)
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5ValueC1Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %number) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %number.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %number, ptr %number.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr %number.addr, align 4
  %call = call noundef ptr @_ZN5ValueC2Ei(ptr noundef nonnull align 4 dereferenceable(4) %this1, i32 noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z5Infixv() #1 personality ptr @__gxx_personality_v0 {
entry:
  %source = alloca %struct.Value, align 4
  %target = alloca %struct.Value, align 4
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %ref.tmp = alloca %struct.Value, align 4
  %ref.tmp4 = alloca %struct.Value, align 4
  %call = call noundef ptr @_ZN5ValueC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %source, i32 noundef 1)
  %call1 = invoke noundef ptr @_ZN5ValueC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %target, i32 noundef 0)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  invoke void @_Z6SourceRK5Value(ptr dead_on_unwind writable sret(%struct.Value) align 4 %ref.tmp, ptr noundef nonnull align 4 dereferenceable(4) %source)
          to label %invoke.cont3 unwind label %lpad2

invoke.cont3:                                     ; preds = %invoke.cont
  %call7 = invoke noundef ptr @_ZN5ValueC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp4, i32 noundef 9)
          to label %invoke.cont6 unwind label %lpad5

invoke.cont6:                                     ; preds = %invoke.cont3
  %call8 = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6TargetR5ValueS0_RKS_(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp4)
  invoke void @_ZN5ValueaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %call8, ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp)
          to label %invoke.cont10 unwind label %lpad9

invoke.cont10:                                    ; preds = %invoke.cont6
  %call11 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp4) #2
  %call13 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp) #2
  %number = getelementptr inbounds nuw %struct.Value, ptr %target, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  %call15 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %target) #2
  %call18 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %source) #2
  ret i32 %0

lpad:                                             ; preds = %entry
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  store ptr %2, ptr %exn.slot, align 8
  %3 = extractvalue { ptr, i32 } %1, 1
  store i32 %3, ptr %ehselector.slot, align 4
  br label %ehcleanup19

lpad2:                                            ; preds = %invoke.cont
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot, align 4
  br label %ehcleanup16

lpad5:                                            ; preds = %invoke.cont3
  %7 = landingpad { ptr, i32 }
          cleanup
  %8 = extractvalue { ptr, i32 } %7, 0
  store ptr %8, ptr %exn.slot, align 8
  %9 = extractvalue { ptr, i32 } %7, 1
  store i32 %9, ptr %ehselector.slot, align 4
  br label %ehcleanup

lpad9:                                            ; preds = %invoke.cont6
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  store ptr %11, ptr %exn.slot, align 8
  %12 = extractvalue { ptr, i32 } %10, 1
  store i32 %12, ptr %ehselector.slot, align 4
  %call12 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp4) #2
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad9, %lpad5
  %call14 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp) #2
  br label %ehcleanup16

ehcleanup16:                                      ; preds = %ehcleanup, %lpad2
  %call17 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %target) #2
  br label %ehcleanup19

ehcleanup19:                                      ; preds = %ehcleanup16, %lpad
  %call20 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %source) #2
  br label %eh.resume

eh.resume:                                        ; preds = %ehcleanup19
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val21 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val21
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr void @_ZN5ValueaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) #0 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  %number2 = getelementptr inbounds nuw %struct.Value, ptr %this1, i32 0, i32 0
  store i32 %1, ptr %number2, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5ValueD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8Explicitv() #1 personality ptr @__gxx_personality_v0 {
entry:
  %source = alloca %struct.Value, align 4
  %target = alloca %struct.Value, align 4
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %ref.tmp = alloca %struct.Value, align 4
  %ref.tmp6 = alloca %struct.Value, align 4
  %call = call noundef ptr @_ZN5ValueC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %source, i32 noundef 1)
  %call1 = invoke noundef ptr @_ZN5ValueC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %target, i32 noundef 0)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %call4 = invoke noundef ptr @_ZN5ValueC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp, i32 noundef 9)
          to label %invoke.cont3 unwind label %lpad2

invoke.cont3:                                     ; preds = %invoke.cont
  %call5 = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6TargetR5ValueS0_RKS_(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp)
  invoke void @_Z6SourceRK5Value(ptr dead_on_unwind writable sret(%struct.Value) align 4 %ref.tmp6, ptr noundef nonnull align 4 dereferenceable(4) %source)
          to label %invoke.cont8 unwind label %lpad7

invoke.cont8:                                     ; preds = %invoke.cont3
  invoke void @_ZN5ValueaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %call5, ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp6)
          to label %invoke.cont10 unwind label %lpad9

invoke.cont10:                                    ; preds = %invoke.cont8
  %call11 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp6) #2
  %call13 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp) #2
  %number = getelementptr inbounds nuw %struct.Value, ptr %target, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  %call15 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %target) #2
  %call18 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %source) #2
  ret i32 %0

lpad:                                             ; preds = %entry
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  store ptr %2, ptr %exn.slot, align 8
  %3 = extractvalue { ptr, i32 } %1, 1
  store i32 %3, ptr %ehselector.slot, align 4
  br label %ehcleanup19

lpad2:                                            ; preds = %invoke.cont
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot, align 4
  br label %ehcleanup16

lpad7:                                            ; preds = %invoke.cont3
  %7 = landingpad { ptr, i32 }
          cleanup
  %8 = extractvalue { ptr, i32 } %7, 0
  store ptr %8, ptr %exn.slot, align 8
  %9 = extractvalue { ptr, i32 } %7, 1
  store i32 %9, ptr %ehselector.slot, align 4
  br label %ehcleanup

lpad9:                                            ; preds = %invoke.cont8
  %10 = landingpad { ptr, i32 }
          cleanup
  %11 = extractvalue { ptr, i32 } %10, 0
  store ptr %11, ptr %exn.slot, align 8
  %12 = extractvalue { ptr, i32 } %10, 1
  store i32 %12, ptr %ehselector.slot, align 4
  %call12 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp6) #2
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad9, %lpad7
  %call14 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %ref.tmp) #2
  br label %ehcleanup16

ehcleanup16:                                      ; preds = %ehcleanup, %lpad2
  %call17 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %target) #2
  br label %ehcleanup19

ehcleanup19:                                      ; preds = %ehcleanup16, %lpad
  %call20 = call noundef ptr @_ZN5ValueD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %source) #2
  br label %eh.resume

eh.resume:                                        ; preds = %ehcleanup19
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val21 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val21
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5ValueC2Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %number) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %number.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %number, ptr %number.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %number2 = getelementptr inbounds nuw %struct.Value, ptr %this1, i32 0, i32 0
  %0 = load i32, ptr %number.addr, align 4
  store i32 %0, ptr %number2, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5ValueD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
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
!6 = !{i64 4}
