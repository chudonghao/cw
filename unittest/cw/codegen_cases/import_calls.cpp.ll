; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names import_calls.cpp -o -
; ModuleID = 'import_calls.cpp'
source_filename = "import_calls.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%"struct.api::Box" = type { i32 }

@global = global %"struct.api::Box" zeroinitializer, align 4
@__dso_handle = external hidden global i8
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_import_calls.cpp, ptr null }]

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_var_init() #0 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  call void @_ZN3api4MakeEv(ptr dead_on_unwind writable sret(%"struct.api::Box") align 4 @global)
  %0 = call i32 @__cxa_atexit(ptr @_ZN3api3BoxD1Ev, ptr @global, ptr @__dso_handle) #3
  ret void
}

declare void @_ZN3api4MakeEv(ptr dead_on_unwind writable sret(%"struct.api::Box") align 4) #1

; Function Attrs: nounwind
declare noundef ptr @_ZN3api3BoxD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4)) unnamed_addr #2

; Function Attrs: nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) #3

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z3Usev() #4 personality ptr @__gxx_personality_v0 {
entry:
  %first = alloca %"struct.api::Box", align 4
  %second = alloca %"struct.api::Box", align 4
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %third = alloca %"struct.api::Box", align 4
  %call = call noundef ptr @_ZN3api3BoxC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %first, i32 noundef 1)
  %call1 = invoke noundef ptr @_ZN3api3BoxC1ERKS0_(ptr noundef nonnull align 4 dereferenceable(4) %second, ptr noundef nonnull align 4 dereferenceable(4) %first)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  invoke void @_ZN3api3BoxaSERKS0_(ptr noundef nonnull align 4 dereferenceable(4) %first, ptr noundef nonnull align 4 dereferenceable(4) %second)
          to label %invoke.cont3 unwind label %lpad2

invoke.cont3:                                     ; preds = %invoke.cont
  invoke void @_ZN3api3BoxaSEOS0_(ptr noundef nonnull align 4 dereferenceable(4) %second, ptr noundef nonnull align 4 dereferenceable(4) %first)
          to label %invoke.cont4 unwind label %lpad2

invoke.cont4:                                     ; preds = %invoke.cont3
  %call6 = invoke noundef ptr @_ZN3api3BoxC1EOS0_(ptr noundef nonnull align 4 dereferenceable(4) %third, ptr noundef nonnull align 4 dereferenceable(4) %second)
          to label %invoke.cont5 unwind label %lpad2

invoke.cont5:                                     ; preds = %invoke.cont4
  invoke void @_ZN3api5FlushEv()
          to label %invoke.cont8 unwind label %lpad7

invoke.cont8:                                     ; preds = %invoke.cont5
  %call10 = invoke noundef i32 @_ZN3api4ReadERKNS_3BoxE(ptr noundef nonnull align 4 dereferenceable(4) %third)
          to label %invoke.cont9 unwind label %lpad7

invoke.cont9:                                     ; preds = %invoke.cont8
  %call11 = call noundef ptr @_ZN3api3BoxD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %third) #3
  %call13 = call noundef ptr @_ZN3api3BoxD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %second) #3
  %call15 = call noundef ptr @_ZN3api3BoxD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %first) #3
  ret i32 %call10

lpad:                                             ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  %1 = extractvalue { ptr, i32 } %0, 0
  store ptr %1, ptr %exn.slot, align 8
  %2 = extractvalue { ptr, i32 } %0, 1
  store i32 %2, ptr %ehselector.slot, align 4
  br label %ehcleanup16

lpad2:                                            ; preds = %invoke.cont4, %invoke.cont3, %invoke.cont
  %3 = landingpad { ptr, i32 }
          cleanup
  %4 = extractvalue { ptr, i32 } %3, 0
  store ptr %4, ptr %exn.slot, align 8
  %5 = extractvalue { ptr, i32 } %3, 1
  store i32 %5, ptr %ehselector.slot, align 4
  br label %ehcleanup

lpad7:                                            ; preds = %invoke.cont8, %invoke.cont5
  %6 = landingpad { ptr, i32 }
          cleanup
  %7 = extractvalue { ptr, i32 } %6, 0
  store ptr %7, ptr %exn.slot, align 8
  %8 = extractvalue { ptr, i32 } %6, 1
  store i32 %8, ptr %ehselector.slot, align 4
  %call12 = call noundef ptr @_ZN3api3BoxD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %third) #3
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad7, %lpad2
  %call14 = call noundef ptr @_ZN3api3BoxD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %second) #3
  br label %ehcleanup16

ehcleanup16:                                      ; preds = %ehcleanup, %lpad
  %call17 = call noundef ptr @_ZN3api3BoxD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %first) #3
  br label %eh.resume

eh.resume:                                        ; preds = %ehcleanup16
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val18 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val18
}

declare noundef ptr @_ZN3api3BoxC1Ei(ptr noundef nonnull returned align 4 dereferenceable(4), i32 noundef) unnamed_addr #1

declare noundef ptr @_ZN3api3BoxC1ERKS0_(ptr noundef nonnull returned align 4 dereferenceable(4), ptr noundef nonnull align 4 dereferenceable(4)) unnamed_addr #1

declare i32 @__gxx_personality_v0(...)

declare void @_ZN3api3BoxaSERKS0_(ptr noundef nonnull align 4 dereferenceable(4), ptr noundef nonnull align 4 dereferenceable(4)) #1

declare void @_ZN3api3BoxaSEOS0_(ptr noundef nonnull align 4 dereferenceable(4), ptr noundef nonnull align 4 dereferenceable(4)) #1

declare noundef ptr @_ZN3api3BoxC1EOS0_(ptr noundef nonnull returned align 4 dereferenceable(4), ptr noundef nonnull align 4 dereferenceable(4)) unnamed_addr #1

declare void @_ZN3api5FlushEv() #1

declare noundef i32 @_ZN3api4ReadERKNS_3BoxE(ptr noundef nonnull align 4 dereferenceable(4)) #1

; Function Attrs: noinline ssp uwtable(sync)
define internal void @_GLOBAL__sub_I_import_calls.cpp() #0 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  call void @__cxx_global_var_init()
  ret void
}

attributes #0 = { noinline ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { nounwind }
attributes #4 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
