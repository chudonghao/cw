; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names object_arguments.cpp -o -
; ModuleID = 'object_arguments.cpp'
source_filename = "object_arguments.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Token = type { i8 }
%struct.Box = type { i8 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7Consume5Tokeni(ptr noundef align 1 %value, i32 noundef %next) #0 {
entry:
  %value.indirect_addr = alloca ptr, align 8
  %next.addr = alloca i32, align 4
  store ptr %value, ptr %value.indirect_addr, align 8
  store i32 %next, ptr %next.addr, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4Nextv() #0 {
entry:
  ret i32 3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z6SelectPFv5TokeniE(ptr noundef %operation) #0 {
entry:
  %operation.addr = alloca ptr, align 8
  store ptr %operation, ptr %operation.addr, align 8
  %0 = load ptr, ptr %operation.addr, align 8
  ret ptr %0
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z9Argumentsv() #1 personality ptr @__gxx_personality_v0 {
entry:
  %source = alloca %struct.Token, align 1
  %agg.tmp = alloca %struct.Token, align 1
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %agg.tmp4 = alloca %struct.Token, align 1
  %operation = alloca ptr, align 8
  %agg.tmp10 = alloca %struct.Token, align 1
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %source)
  %call1 = invoke noundef ptr @_ZN5TokenC1ERKS_(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp, ptr noundef nonnull align 1 dereferenceable(1) %source)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %call2 = call noundef i32 @_Z4Nextv()
  call void @_Z7Consume5Tokeni(ptr noundef align 1 %agg.tmp, i32 noundef %call2)
  %call3 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp) #2
  %call6 = invoke noundef ptr @_ZN5TokenC1EOS_(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp4, ptr noundef nonnull align 1 dereferenceable(1) %source)
          to label %invoke.cont5 unwind label %lpad

invoke.cont5:                                     ; preds = %invoke.cont
  %call7 = call noundef i32 @_Z4Nextv()
  call void @_Z7Consume5Tokeni(ptr noundef align 1 %agg.tmp4, i32 noundef %call7)
  %call8 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp4) #2
  store ptr @_Z7Consume5Tokeni, ptr %operation, align 8
  %0 = load ptr, ptr %operation, align 8
  %call9 = call noundef ptr @_Z6SelectPFv5TokeniE(ptr noundef %0)
  %call12 = invoke noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp10)
          to label %invoke.cont11 unwind label %lpad

invoke.cont11:                                    ; preds = %invoke.cont5
  %call13 = call noundef i32 @_Z4Nextv()
  invoke void %call9(ptr noundef align 1 %agg.tmp10, i32 noundef %call13)
          to label %invoke.cont15 unwind label %lpad14

invoke.cont15:                                    ; preds = %invoke.cont11
  %call16 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp10) #2
  %call18 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %source) #2
  ret void

lpad:                                             ; preds = %invoke.cont5, %invoke.cont, %entry
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  store ptr %2, ptr %exn.slot, align 8
  %3 = extractvalue { ptr, i32 } %1, 1
  store i32 %3, ptr %ehselector.slot, align 4
  br label %ehcleanup

lpad14:                                           ; preds = %invoke.cont11
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot, align 4
  %call17 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp10) #2
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad14, %lpad
  %call19 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %source) #2
  br label %eh.resume

eh.resume:                                        ; preds = %ehcleanup
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val20 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val20
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

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC1ERKS_(ptr noundef nonnull returned align 1 dereferenceable(1) %this, ptr noundef nonnull align 1 dereferenceable(1) %0) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN5TokenC2ERKS_(ptr noundef nonnull align 1 dereferenceable(1) %this1, ptr noundef nonnull align 1 dereferenceable(1) %1)
  ret ptr %this1
}

declare i32 @__gxx_personality_v0(...)

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
define linkonce_odr noundef ptr @_ZN5TokenC1EOS_(ptr noundef nonnull returned align 1 dereferenceable(1) %this, ptr noundef nonnull align 1 dereferenceable(1) %0) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN5TokenC2EOS_(ptr noundef nonnull align 1 dereferenceable(1) %this1, ptr noundef nonnull align 1 dereferenceable(1) %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4Packv() #1 personality ptr @__gxx_personality_v0 {
entry:
  %box = alloca %struct.Box, align 1
  %agg.tmp = alloca %struct.Token, align 1
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp)
  %call1 = call noundef i32 @_Z4Nextv()
  %call2 = invoke noundef ptr @_ZN3BoxC1E5Tokeni(ptr noundef nonnull align 1 dereferenceable(1) %box, ptr noundef align 1 %agg.tmp, i32 noundef %call1)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %call3 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp) #2
  %call5 = call noundef ptr @_ZN3BoxD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %box) #2
  ret void

lpad:                                             ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  %1 = extractvalue { ptr, i32 } %0, 0
  store ptr %1, ptr %exn.slot, align 8
  %2 = extractvalue { ptr, i32 } %0, 1
  store i32 %2, ptr %ehselector.slot, align 4
  %call4 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp) #2
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val6 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val6
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN3BoxC1E5Tokeni(ptr noundef nonnull returned align 1 dereferenceable(1) %this, ptr noundef align 1 %value, i32 noundef %next) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %value.indirect_addr = alloca ptr, align 8
  %next.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %value, ptr %value.indirect_addr, align 8
  store i32 %next, ptr %next.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr %next.addr, align 4
  %call = call noundef ptr @_ZN3BoxC2E5Tokeni(ptr noundef nonnull align 1 dereferenceable(1) %this1, ptr noundef align 1 %value, i32 noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN3BoxD1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN3BoxD2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC2ERKS_(ptr noundef nonnull returned align 1 dereferenceable(1) %this, ptr noundef nonnull align 1 dereferenceable(1) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
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

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC2EOS_(ptr noundef nonnull returned align 1 dereferenceable(1) %this, ptr noundef nonnull align 1 dereferenceable(1) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN3BoxC2E5Tokeni(ptr noundef nonnull returned align 1 dereferenceable(1) %this, ptr noundef align 1 %value, i32 noundef %next) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %value.indirect_addr = alloca ptr, align 8
  %next.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %value, ptr %value.indirect_addr, align 8
  store i32 %next, ptr %next.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN3BoxD2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
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
