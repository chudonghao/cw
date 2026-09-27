; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names object_results.cpp -o -
; ModuleID = 'object_results.cpp'
source_filename = "object_results.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Item = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7InspectRK4Item(ptr noundef nonnull align 4 dereferenceable(4) %0) #0 {
entry:
  %.addr = alloca ptr, align 8
  store ptr %0, ptr %.addr, align 8
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4Makev(ptr dead_on_unwind noalias writable sret(%struct.Item) align 4 %agg.result) #1 {
entry:
  %result.ptr = alloca ptr, align 8
  store ptr %agg.result, ptr %result.ptr, align 8
  %call = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %agg.result, i32 noundef 1)
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %value) unnamed_addr #1 {
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

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z5Namedv(ptr dead_on_unwind noalias writable sret(%struct.Item) align 4 %agg.result) #1 {
entry:
  %result.ptr = alloca ptr, align 8
  %nrvo = alloca i1, align 1
  store ptr %agg.result, ptr %result.ptr, align 8
  store i1 false, ptr %nrvo, align 1
  %call = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %agg.result, i32 noundef 2)
  call void @_Z7InspectRK4Item(ptr noundef nonnull align 4 dereferenceable(4) %agg.result)
  store i1 true, ptr %nrvo, align 1
  %nrvo.val = load i1, ptr %nrvo, align 1
  br i1 %nrvo.val, label %nrvo.skipdtor, label %nrvo.unused

nrvo.unused:                                      ; preds = %entry
  %call1 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %agg.result) #2
  br label %nrvo.skipdtor

nrvo.skipdtor:                                    ; preds = %nrvo.unused, %entry
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6Selectb(ptr dead_on_unwind noalias writable sret(%struct.Item) align 4 %agg.result, i1 noundef zeroext %flag) #1 {
entry:
  %result.ptr = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  store ptr %agg.result, ptr %result.ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  call void @_Z4Makev(ptr dead_on_unwind writable sret(%struct.Item) align 4 %agg.result)
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @_Z5Namedv(ptr dead_on_unwind writable sret(%struct.Item) align 4 %agg.result)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z7Resultsv() #1 personality ptr @__gxx_personality_v0 {
entry:
  %value = alloca %struct.Item, align 4
  %agg.tmp.ensured = alloca %struct.Item, align 4
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  call void @_Z4Makev(ptr dead_on_unwind writable sret(%struct.Item) align 4 %value)
  call void @_Z7InspectRK4Item(ptr noundef nonnull align 4 dereferenceable(4) %value)
  invoke void @_Z5Namedv(ptr dead_on_unwind writable sret(%struct.Item) align 4 %agg.tmp.ensured)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %call = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %agg.tmp.ensured) #2
  %call1 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %value) #2
  ret void

lpad:                                             ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  %1 = extractvalue { ptr, i32 } %0, 0
  store ptr %1, ptr %exn.slot, align 8
  %2 = extractvalue { ptr, i32 } %0, 1
  store i32 %2, ptr %ehselector.slot, align 4
  %call2 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %value) #2
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val3 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val3
}

declare i32 @__gxx_personality_v0(...)

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
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
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
