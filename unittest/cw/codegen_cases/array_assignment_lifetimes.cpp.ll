; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names array_assignment_lifetimes.cpp -o -
; ModuleID = 'array_assignment_lifetimes.cpp'
source_filename = "array_assignment_lifetimes.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Token = type <{ ptr, i32, [4 x i8] }>
%struct.Receipt = type { ptr }
%struct.Pair = type { [2 x %struct.Item] }
%struct.Item = type { ptr }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(16) ptr @_Z6SourceRK4PairRK5Token(ptr noundef nonnull align 8 dereferenceable(16) %source, ptr noundef nonnull align 8 dereferenceable(12) %token) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %token.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %token, ptr %token.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(16) ptr @_Z6TargetR4PairRK5Token(ptr noundef nonnull align 8 dereferenceable(16) %target, ptr noundef nonnull align 8 dereferenceable(12) %token) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %token.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %token, ptr %token.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6AssignR4PairRKS_Ri(ptr noundef nonnull align 8 dereferenceable(16) %target, ptr noundef nonnull align 8 dereferenceable(16) %source, ptr noundef nonnull align 4 dereferenceable(4) %trace) #1 personality ptr @__gxx_personality_v0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %trace.addr = alloca ptr, align 8
  %ref.tmp = alloca %struct.Token, align 8
  %ref.tmp2 = alloca %struct.Token, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %trace, ptr %trace.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %trace.addr, align 8, !nonnull !5, !align !7
  %call = call noundef ptr @_ZN5TokenC1EPii(ptr noundef nonnull align 8 dereferenceable(12) %ref.tmp, ptr noundef %1, i32 noundef 4)
  %call1 = call noundef nonnull align 8 dereferenceable(16) ptr @_Z6SourceRK4PairRK5Token(ptr noundef nonnull align 8 dereferenceable(16) %0, ptr noundef nonnull align 8 dereferenceable(12) %ref.tmp)
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %trace.addr, align 8, !nonnull !5, !align !7
  %call3 = invoke noundef ptr @_ZN5TokenC1EPii(ptr noundef nonnull align 8 dereferenceable(12) %ref.tmp2, ptr noundef %3, i32 noundef 5)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %call4 = call noundef nonnull align 8 dereferenceable(16) ptr @_Z6TargetR4PairRK5Token(ptr noundef nonnull align 8 dereferenceable(16) %2, ptr noundef nonnull align 8 dereferenceable(12) %ref.tmp2)
  %call7 = invoke noundef nonnull align 8 dereferenceable(16) ptr @_ZN4PairaSERKS_(ptr noundef nonnull align 8 dereferenceable(16) %call4, ptr noundef nonnull align 8 dereferenceable(16) %call1)
          to label %invoke.cont6 unwind label %lpad5

invoke.cont6:                                     ; preds = %invoke.cont
  %call8 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %ref.tmp2) #2
  %call10 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %ref.tmp) #2
  ret void

lpad:                                             ; preds = %entry
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot, align 4
  br label %ehcleanup

lpad5:                                            ; preds = %invoke.cont
  %7 = landingpad { ptr, i32 }
          cleanup
  %8 = extractvalue { ptr, i32 } %7, 0
  store ptr %8, ptr %exn.slot, align 8
  %9 = extractvalue { ptr, i32 } %7, 1
  store i32 %9, ptr %ehselector.slot, align 4
  %call9 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %ref.tmp2) #2
  br label %ehcleanup

ehcleanup:                                        ; preds = %lpad5, %lpad
  %call11 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %ref.tmp) #2
  br label %eh.resume

eh.resume:                                        ; preds = %ehcleanup
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val12 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val12
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC1EPii(ptr noundef nonnull returned align 8 dereferenceable(12) %this, ptr noundef %trace, i32 noundef %tag) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %trace.addr = alloca ptr, align 8
  %tag.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %trace, ptr %trace.addr, align 8
  store i32 %tag, ptr %tag.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %trace.addr, align 8
  %1 = load i32, ptr %tag.addr, align 4
  %call = call noundef ptr @_ZN5TokenC2EPii(ptr noundef nonnull align 8 dereferenceable(12) %this1, ptr noundef %0, i32 noundef %1)
  ret ptr %this1
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 8 dereferenceable(16) ptr @_ZN4PairaSERKS_(ptr noundef nonnull align 8 dereferenceable(16) %this, ptr noundef nonnull align 8 dereferenceable(16) %0) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %__i0 = alloca i64, align 8
  %agg.tmp.ensured = alloca %struct.Receipt, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store i64 0, ptr %__i0, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i64, ptr %__i0, align 8
  %cmp = icmp ne i64 %1, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %elements = getelementptr inbounds nuw %struct.Pair, ptr %this1, i32 0, i32 0
  %2 = load i64, ptr %__i0, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Item], ptr %elements, i64 0, i64 %2
  %3 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements2 = getelementptr inbounds nuw %struct.Pair, ptr %3, i32 0, i32 0
  %4 = load i64, ptr %__i0, align 8
  %arrayidx3 = getelementptr inbounds nuw [2 x %struct.Item], ptr %elements2, i64 0, i64 %4
  call void @_ZN4ItemaSERKS_(ptr dead_on_unwind writable sret(%struct.Receipt) align 8 %agg.tmp.ensured, ptr noundef nonnull align 8 dereferenceable(8) %arrayidx, ptr noundef nonnull align 8 dereferenceable(8) %arrayidx3)
  %call = call noundef ptr @_ZN7ReceiptD1Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %agg.tmp.ensured) #2
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i64, ptr %__i0, align 8
  %inc = add i64 %5, 1
  store i64 %inc, ptr %__i0, align 8
  br label %for.cond, !llvm.loop !8

for.end:                                          ; preds = %for.cond
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5TokenD2Ev(ptr noundef nonnull align 8 dead_on_return(12) dereferenceable(12) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z11ConditionalbR4PairRKS_(i1 noundef zeroext %flag, ptr noundef nonnull align 8 dereferenceable(16) %target, ptr noundef nonnull align 8 dereferenceable(16) %source) #1 {
entry:
  %flag.addr = alloca i8, align 1
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 8 dereferenceable(16) ptr @_ZN4PairaSERKS_(ptr noundef nonnull align 8 dereferenceable(16) %2, ptr noundef nonnull align 8 dereferenceable(16) %1)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %3 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %call, %cond.true ], [ %3, %cond.false ]
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC2EPii(ptr noundef nonnull returned align 8 dereferenceable(12) %this, ptr noundef %trace, i32 noundef %tag) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %trace.addr = alloca ptr, align 8
  %tag.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %trace, ptr %trace.addr, align 8
  store i32 %tag, ptr %tag.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %trace2 = getelementptr inbounds nuw %struct.Token, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %trace.addr, align 8
  store ptr %0, ptr %trace2, align 8
  %tag3 = getelementptr inbounds nuw %struct.Token, ptr %this1, i32 0, i32 1
  %1 = load i32, ptr %tag.addr, align 4
  store i32 %1, ptr %tag3, align 8
  %2 = load ptr, ptr %trace.addr, align 8
  %3 = load i32, ptr %2, align 4
  %mul = mul nsw i32 %3, 10
  %4 = load i32, ptr %tag.addr, align 4
  %add = add nsw i32 %mul, %4
  %5 = load ptr, ptr %trace.addr, align 8
  store i32 %add, ptr %5, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr void @_ZN4ItemaSERKS_(ptr dead_on_unwind noalias writable sret(%struct.Receipt) align 8 %agg.result, ptr noundef nonnull align 8 dereferenceable(8) %this, ptr noundef nonnull align 8 dereferenceable(8) %source) #1 {
entry:
  %result.ptr = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %agg.result, ptr %result.ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %trace = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %trace, align 8
  %1 = load i32, ptr %0, align 4
  %mul = mul nsw i32 %1, 10
  %add = add nsw i32 %mul, 1
  %trace2 = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  %2 = load ptr, ptr %trace2, align 8
  store i32 %add, ptr %2, align 4
  %trace3 = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  %3 = load ptr, ptr %trace3, align 8
  %call = call noundef ptr @_ZN7ReceiptC1EPi(ptr noundef nonnull align 8 dereferenceable(8) %agg.result, ptr noundef %3)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN7ReceiptD1Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7ReceiptD2Ev(ptr noundef nonnull align 8 dead_on_return(8) dereferenceable(8) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN7ReceiptC1EPi(ptr noundef nonnull returned align 8 dereferenceable(8) %this, ptr noundef %trace) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %trace.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %trace, ptr %trace.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %trace.addr, align 8
  %call = call noundef ptr @_ZN7ReceiptC2EPi(ptr noundef nonnull align 8 dereferenceable(8) %this1, ptr noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN7ReceiptC2EPi(ptr noundef nonnull returned align 8 dereferenceable(8) %this, ptr noundef %trace) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %trace.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %trace, ptr %trace.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %trace2 = getelementptr inbounds nuw %struct.Receipt, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %trace.addr, align 8
  store ptr %0, ptr %trace2, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN7ReceiptD2Ev(ptr noundef nonnull returned align 8 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %trace = getelementptr inbounds nuw %struct.Receipt, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %trace, align 8
  %1 = load i32, ptr %0, align 4
  %mul = mul nsw i32 %1, 10
  %add = add nsw i32 %mul, 2
  %trace2 = getelementptr inbounds nuw %struct.Receipt, ptr %this1, i32 0, i32 0
  %2 = load ptr, ptr %trace2, align 8
  store i32 %add, ptr %2, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenD2Ev(ptr noundef nonnull returned align 8 dead_on_return(12) dereferenceable(12) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %trace = getelementptr inbounds nuw %struct.Token, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %trace, align 8
  %1 = load i32, ptr %0, align 4
  %mul = mul nsw i32 %1, 10
  %tag = getelementptr inbounds nuw %struct.Token, ptr %this1, i32 0, i32 1
  %2 = load i32, ptr %tag, align 8
  %add = add nsw i32 %mul, %2
  %trace2 = getelementptr inbounds nuw %struct.Token, ptr %this1, i32 0, i32 0
  %3 = load ptr, ptr %trace2, align 8
  store i32 %add, ptr %3, align 4
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
!6 = !{i64 8}
!7 = !{i64 4}
!8 = distinct !{!8, !9}
!9 = !{!"llvm.loop.mustprogress"}
