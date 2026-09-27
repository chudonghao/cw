; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names object_arrays.cpp -o -
; ModuleID = 'object_arrays.cpp'
source_filename = "object_arrays.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Pair = type { [2 x %struct.Item] }
%struct.Item = type { i32 }
%struct.Matrix = type { [1 x [2 x %struct.Item]] }
%struct.ZeroArray = type { [0 x %struct.Item] }
%struct.ZeroMatrix = type { [3 x [0 x %struct.Item]] }
%struct.Empty = type { i8 }
%struct.EmptyPair = type { [2 x %struct.Empty] }
%struct.HolderPair = type { [2 x %struct.Holder] }
%struct.Holder = type { i8, [0 x %struct.Item] }

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4CopyRK4Pair(ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca %struct.Pair, align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef ptr @_ZN4PairC1ERKS_(ptr noundef nonnull align 4 dereferenceable(8) %value, ptr noundef nonnull align 4 dereferenceable(8) %0)
  %call1 = call noundef ptr @_ZN4PairD1Ev(ptr noundef nonnull align 4 dead_on_return(8) dereferenceable(8) %value) #2
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4PairC1ERKS_(ptr noundef nonnull returned align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN4PairC2ERKS_(ptr noundef nonnull align 4 dereferenceable(8) %this1, ptr noundef nonnull align 4 dereferenceable(8) %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4PairD1Ev(ptr noundef nonnull returned align 4 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4PairD2Ev(ptr noundef nonnull align 4 dead_on_return(8) dereferenceable(8) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4MoveO4Pair(ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca %struct.Pair, align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef ptr @_ZN4PairC1EOS_(ptr noundef nonnull align 4 dereferenceable(8) %value, ptr noundef nonnull align 4 dereferenceable(8) %0)
  %call1 = call noundef ptr @_ZN4PairD1Ev(ptr noundef nonnull align 4 dead_on_return(8) dereferenceable(8) %value) #2
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4PairC1EOS_(ptr noundef nonnull returned align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN4PairC2EOS_(ptr noundef nonnull align 4 dereferenceable(8) %this1, ptr noundef nonnull align 4 dereferenceable(8) %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6NestedRK6Matrix(ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca %struct.Matrix, align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef ptr @_ZN6MatrixC1ERKS_(ptr noundef nonnull align 4 dereferenceable(8) %value, ptr noundef nonnull align 4 dereferenceable(8) %0)
  %call1 = call noundef ptr @_ZN6MatrixD1Ev(ptr noundef nonnull align 4 dead_on_return(8) dereferenceable(8) %value) #2
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6MatrixC1ERKS_(ptr noundef nonnull returned align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN6MatrixC2ERKS_(ptr noundef nonnull align 4 dereferenceable(8) %this1, ptr noundef nonnull align 4 dereferenceable(8) %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6MatrixD1Ev(ptr noundef nonnull returned align 4 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN6MatrixD2Ev(ptr noundef nonnull align 4 dead_on_return(8) dereferenceable(8) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4ZeroRK9ZeroArray(ptr noundef nonnull align 4 dereferenceable(1) %source) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca %struct.ZeroArray, align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef ptr @_ZN9ZeroArrayC1ERKS_(ptr noundef nonnull align 4 dereferenceable(1) %value, ptr noundef nonnull align 4 dereferenceable(1) %0)
  %call1 = call noundef ptr @_ZN9ZeroArrayD1Ev(ptr noundef nonnull align 4 dereferenceable(1) %value) #2
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN9ZeroArrayC1ERKS_(ptr noundef nonnull returned align 4 dereferenceable(1) %this, ptr noundef nonnull align 4 dereferenceable(1) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN9ZeroArrayC2ERKS_(ptr noundef nonnull align 4 dereferenceable(1) %this1, ptr noundef nonnull align 4 dereferenceable(1) %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN9ZeroArrayD1Ev(ptr noundef nonnull returned align 4 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN9ZeroArrayD2Ev(ptr noundef nonnull align 4 dereferenceable(1) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(1) ptr @_Z10ZeroSourceRK10ZeroMatrixRi(ptr noundef nonnull align 4 dereferenceable(1) %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) #1 {
entry:
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  ret ptr %3
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z10NestedZeroRK10ZeroMatrixRi(ptr noundef nonnull align 4 dereferenceable(1) %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %value = alloca %struct.ZeroMatrix, align 4
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(1) ptr @_Z10ZeroSourceRK10ZeroMatrixRi(ptr noundef nonnull align 4 dereferenceable(1) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %call1 = call noundef ptr @_ZN10ZeroMatrixC1ERKS_(ptr noundef nonnull align 4 dereferenceable(1) %value, ptr noundef nonnull align 4 dereferenceable(1) %call)
  %call2 = call noundef ptr @_ZN10ZeroMatrixD1Ev(ptr noundef nonnull align 4 dereferenceable(1) %value) #2
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN10ZeroMatrixC1ERKS_(ptr noundef nonnull returned align 4 dereferenceable(1) %this, ptr noundef nonnull align 4 dereferenceable(1) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN10ZeroMatrixC2ERKS_(ptr noundef nonnull align 4 dereferenceable(1) %this1, ptr noundef nonnull align 4 dereferenceable(1) %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN10ZeroMatrixD1Ev(ptr noundef nonnull returned align 4 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN10ZeroMatrixD2Ev(ptr noundef nonnull align 4 dereferenceable(1) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z13EmptyElementsv() #0 personality ptr @__gxx_personality_v0 {
entry:
  %value = alloca [2 x %struct.Empty], align 1
  %arrayinit.endOfInit = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %value, ptr %arrayinit.endOfInit, align 8
  %call = invoke noundef ptr @_ZN5EmptyC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %value)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %arrayinit.element = getelementptr inbounds %struct.Empty, ptr %value, i64 1
  store ptr %arrayinit.element, ptr %arrayinit.endOfInit, align 8
  %call2 = invoke noundef ptr @_ZN5EmptyC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %arrayinit.element)
          to label %invoke.cont1 unwind label %lpad

invoke.cont1:                                     ; preds = %invoke.cont
  %array.begin = getelementptr inbounds [2 x %struct.Empty], ptr %value, i32 0, i32 0
  %0 = getelementptr inbounds %struct.Empty, ptr %array.begin, i64 2
  br label %arraydestroy.body5

arraydestroy.body5:                               ; preds = %arraydestroy.body5, %invoke.cont1
  %arraydestroy.elementPast6 = phi ptr [ %0, %invoke.cont1 ], [ %arraydestroy.element7, %arraydestroy.body5 ]
  %arraydestroy.element7 = getelementptr inbounds %struct.Empty, ptr %arraydestroy.elementPast6, i64 -1
  %call8 = call noundef ptr @_ZN5EmptyD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %arraydestroy.element7) #2
  %arraydestroy.done9 = icmp eq ptr %arraydestroy.element7, %array.begin
  br i1 %arraydestroy.done9, label %arraydestroy.done10, label %arraydestroy.body5

arraydestroy.done10:                              ; preds = %arraydestroy.body5
  ret void

lpad:                                             ; preds = %invoke.cont, %entry
  %1 = landingpad { ptr, i32 }
          cleanup
  %2 = extractvalue { ptr, i32 } %1, 0
  store ptr %2, ptr %exn.slot, align 8
  %3 = extractvalue { ptr, i32 } %1, 1
  store i32 %3, ptr %ehselector.slot, align 4
  %4 = load ptr, ptr %arrayinit.endOfInit, align 8
  %arraydestroy.isempty = icmp eq ptr %value, %4
  br i1 %arraydestroy.isempty, label %arraydestroy.done4, label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %lpad
  %arraydestroy.elementPast = phi ptr [ %4, %lpad ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Empty, ptr %arraydestroy.elementPast, i64 -1
  %call3 = call noundef ptr @_ZN5EmptyD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %value
  br i1 %arraydestroy.done, label %arraydestroy.done4, label %arraydestroy.body

arraydestroy.done4:                               ; preds = %arraydestroy.body, %lpad
  br label %eh.resume

eh.resume:                                        ; preds = %arraydestroy.done4
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val11 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val11
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5EmptyC1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5EmptyC2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1)
  ret ptr %this1
}

declare i32 @__gxx_personality_v0(...)

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5EmptyD1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5EmptyD2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z9CopyEmptyRK9EmptyPair(ptr noundef nonnull align 1 dereferenceable(2) %source) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca %struct.EmptyPair, align 1
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5
  %call = call noundef ptr @_ZN9EmptyPairC1ERKS_(ptr noundef nonnull align 1 dereferenceable(2) %value, ptr noundef nonnull align 1 dereferenceable(2) %0)
  %call1 = call noundef ptr @_ZN9EmptyPairD1Ev(ptr noundef nonnull align 1 dead_on_return(2) dereferenceable(2) %value) #2
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN9EmptyPairC1ERKS_(ptr noundef nonnull returned align 1 dereferenceable(2) %this, ptr noundef nonnull align 1 dereferenceable(2) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN9EmptyPairC2ERKS_(ptr noundef nonnull align 1 dereferenceable(2) %this1, ptr noundef nonnull align 1 dereferenceable(2) %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN9EmptyPairD1Ev(ptr noundef nonnull returned align 1 dead_on_return(2) dereferenceable(2) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN9EmptyPairD2Ev(ptr noundef nonnull align 1 dead_on_return(2) dereferenceable(2) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z10EmptyValue5Empty(ptr dead_on_unwind noalias writable sret(%struct.Empty) align 1 %agg.result, ptr noundef align 1 %value) #0 {
entry:
  %result.ptr = alloca ptr, align 8
  %value.indirect_addr = alloca ptr, align 8
  store ptr %agg.result, ptr %result.ptr, align 8
  store ptr %value, ptr %value.indirect_addr, align 8
  %call = call noundef ptr @_ZN5EmptyC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.result)
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z7Discardv() #0 personality ptr @__gxx_personality_v0 {
entry:
  %agg.tmp.ensured = alloca %struct.Empty, align 1
  %agg.tmp = alloca %struct.Empty, align 1
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %call = call noundef ptr @_ZN5EmptyC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp)
  invoke void @_Z10EmptyValue5Empty(ptr dead_on_unwind writable sret(%struct.Empty) align 1 %agg.tmp.ensured, ptr noundef align 1 %agg.tmp)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %entry
  %call1 = call noundef ptr @_ZN5EmptyD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp.ensured) #2
  %call2 = call noundef ptr @_ZN5EmptyD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp) #2
  ret void

lpad:                                             ; preds = %entry
  %0 = landingpad { ptr, i32 }
          cleanup
  %1 = extractvalue { ptr, i32 } %0, 0
  store ptr %1, ptr %exn.slot, align 8
  %2 = extractvalue { ptr, i32 } %0, 1
  store i32 %2, ptr %ehselector.slot, align 4
  %call3 = call noundef ptr @_ZN5EmptyD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp) #2
  br label %eh.resume

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val4 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val4
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z7HoldersRK10HolderPair(ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca %struct.HolderPair, align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef ptr @_ZN10HolderPairC1ERKS_(ptr noundef nonnull align 4 dereferenceable(8) %value, ptr noundef nonnull align 4 dereferenceable(8) %0)
  %call1 = call noundef ptr @_ZN10HolderPairD1Ev(ptr noundef nonnull align 4 dead_on_return(8) dereferenceable(8) %value) #2
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN10HolderPairC1ERKS_(ptr noundef nonnull returned align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %1 = load ptr, ptr %.addr, align 8
  %call = call noundef ptr @_ZN10HolderPairC2ERKS_(ptr noundef nonnull align 4 dereferenceable(8) %this1, ptr noundef nonnull align 4 dereferenceable(8) %1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN10HolderPairD1Ev(ptr noundef nonnull returned align 4 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN10HolderPairD2Ev(ptr noundef nonnull align 4 dead_on_return(8) dereferenceable(8) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4PairC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.Pair, ptr %this1, i32 0, i32 0
  %1 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements2 = getelementptr inbounds nuw %struct.Pair, ptr %1, i32 0, i32 0
  %arrayinit.begin = getelementptr inbounds [2 x %struct.Item], ptr %elements, i64 0, i64 0
  br label %arrayinit.body

arrayinit.body:                                   ; preds = %invoke.cont, %entry
  %arrayinit.index = phi i64 [ 0, %entry ], [ %arrayinit.next, %invoke.cont ]
  %2 = getelementptr inbounds %struct.Item, ptr %arrayinit.begin, i64 %arrayinit.index
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Item], ptr %elements2, i64 0, i64 %arrayinit.index
  %call = invoke noundef ptr @_ZN4ItemC1ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %arrayinit.body
  %arrayinit.next = add nuw i64 %arrayinit.index, 1
  %arrayinit.done = icmp eq i64 %arrayinit.next, 2
  br i1 %arrayinit.done, label %arrayinit.end, label %arrayinit.body

arrayinit.end:                                    ; preds = %invoke.cont
  %3 = load ptr, ptr %retval, align 8
  ret ptr %3

lpad:                                             ; preds = %arrayinit.body
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot, align 4
  %arraydestroy.isempty = icmp eq ptr %arrayinit.begin, %2
  br i1 %arraydestroy.isempty, label %arraydestroy.done4, label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %lpad
  %arraydestroy.elementPast = phi ptr [ %2, %lpad ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Item, ptr %arraydestroy.elementPast, i64 -1
  %call3 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %arrayinit.begin
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
define linkonce_odr noundef ptr @_ZN4ItemC1ERKS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %other) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %other, ptr %other.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %other.addr, align 8
  %call = call noundef ptr @_ZN4ItemC2ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %other) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %other, ptr %other.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %other.addr, align 8, !nonnull !5, !align !6
  %value2 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value2, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4PairD2Ev(ptr noundef nonnull returned align 4 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #1 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.Pair, ptr %this1, i32 0, i32 0
  %array.begin = getelementptr inbounds [2 x %struct.Item], ptr %elements, i32 0, i32 0
  %0 = getelementptr inbounds %struct.Item, ptr %array.begin, i64 2
  br label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %entry
  %arraydestroy.elementPast = phi ptr [ %0, %entry ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Item, ptr %arraydestroy.elementPast, i64 -1
  %call = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %array.begin
  br i1 %arraydestroy.done, label %arraydestroy.done2, label %arraydestroy.body

arraydestroy.done2:                               ; preds = %arraydestroy.body
  %1 = load ptr, ptr %retval, align 8
  ret ptr %1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4PairC2EOS_(ptr noundef nonnull returned align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.Pair, ptr %this1, i32 0, i32 0
  %1 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements2 = getelementptr inbounds nuw %struct.Pair, ptr %1, i32 0, i32 0
  %arrayinit.begin = getelementptr inbounds [2 x %struct.Item], ptr %elements, i64 0, i64 0
  br label %arrayinit.body

arrayinit.body:                                   ; preds = %invoke.cont, %entry
  %arrayinit.index = phi i64 [ 0, %entry ], [ %arrayinit.next, %invoke.cont ]
  %2 = getelementptr inbounds %struct.Item, ptr %arrayinit.begin, i64 %arrayinit.index
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Item], ptr %elements2, i64 0, i64 %arrayinit.index
  %call = invoke noundef ptr @_ZN4ItemC1EOS_(ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %arrayinit.body
  %arrayinit.next = add nuw i64 %arrayinit.index, 1
  %arrayinit.done = icmp eq i64 %arrayinit.next, 2
  br i1 %arrayinit.done, label %arrayinit.end, label %arrayinit.body

arrayinit.end:                                    ; preds = %invoke.cont
  %3 = load ptr, ptr %retval, align 8
  ret ptr %3

lpad:                                             ; preds = %arrayinit.body
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot, align 4
  %arraydestroy.isempty = icmp eq ptr %arrayinit.begin, %2
  br i1 %arraydestroy.isempty, label %arraydestroy.done4, label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %lpad
  %arraydestroy.elementPast = phi ptr [ %2, %lpad ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Item, ptr %arraydestroy.elementPast, i64 -1
  %call3 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %arrayinit.begin
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
define linkonce_odr noundef ptr @_ZN4ItemC1EOS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %other) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %other, ptr %other.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %other.addr, align 8
  %call = call noundef ptr @_ZN4ItemC2EOS_(ptr noundef nonnull align 4 dereferenceable(4) %this1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC2EOS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %other) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %other, ptr %other.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %other.addr, align 8, !nonnull !5, !align !6
  %value2 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value2, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6MatrixC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.Matrix, ptr %this1, i32 0, i32 0
  %1 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements2 = getelementptr inbounds nuw %struct.Matrix, ptr %1, i32 0, i32 0
  %arrayinit.begin = getelementptr inbounds [1 x [2 x %struct.Item]], ptr %elements, i64 0, i64 0
  br label %arrayinit.body

arrayinit.body:                                   ; preds = %arrayinit.end, %entry
  %arrayinit.index = phi i64 [ 0, %entry ], [ %arrayinit.next9, %arrayinit.end ]
  %2 = getelementptr inbounds [2 x %struct.Item], ptr %arrayinit.begin, i64 %arrayinit.index
  %arrayidx = getelementptr inbounds nuw [1 x [2 x %struct.Item]], ptr %elements2, i64 0, i64 %arrayinit.index
  %arrayinit.begin3 = getelementptr inbounds [2 x %struct.Item], ptr %2, i64 0, i64 0
  br label %arrayinit.body4

arrayinit.body4:                                  ; preds = %invoke.cont, %arrayinit.body
  %arrayinit.index5 = phi i64 [ 0, %arrayinit.body ], [ %arrayinit.next, %invoke.cont ]
  %3 = getelementptr inbounds %struct.Item, ptr %arrayinit.begin3, i64 %arrayinit.index5
  %arrayidx6 = getelementptr inbounds nuw [2 x %struct.Item], ptr %arrayidx, i64 0, i64 %arrayinit.index5
  %call = invoke noundef ptr @_ZN4ItemC1ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %3, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx6)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %arrayinit.body4
  %arrayinit.next = add nuw i64 %arrayinit.index5, 1
  %arrayinit.done = icmp eq i64 %arrayinit.next, 2
  br i1 %arrayinit.done, label %arrayinit.end, label %arrayinit.body4

arrayinit.end:                                    ; preds = %invoke.cont
  %arrayinit.next9 = add nuw i64 %arrayinit.index, 1
  %arrayinit.done10 = icmp eq i64 %arrayinit.next9, 1
  br i1 %arrayinit.done10, label %arrayinit.end11, label %arrayinit.body

arrayinit.end11:                                  ; preds = %arrayinit.end
  %4 = load ptr, ptr %retval, align 8
  ret ptr %4

lpad:                                             ; preds = %arrayinit.body4
  %5 = landingpad { ptr, i32 }
          cleanup
  %6 = extractvalue { ptr, i32 } %5, 0
  store ptr %6, ptr %exn.slot, align 8
  %7 = extractvalue { ptr, i32 } %5, 1
  store i32 %7, ptr %ehselector.slot, align 4
  %arraydestroy.isempty = icmp eq ptr %arrayinit.begin, %3
  br i1 %arraydestroy.isempty, label %arraydestroy.done8, label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %lpad
  %arraydestroy.elementPast = phi ptr [ %3, %lpad ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Item, ptr %arraydestroy.elementPast, i64 -1
  %call7 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %arrayinit.begin
  br i1 %arraydestroy.done, label %arraydestroy.done8, label %arraydestroy.body

arraydestroy.done8:                               ; preds = %arraydestroy.body, %lpad
  br label %eh.resume

eh.resume:                                        ; preds = %arraydestroy.done8
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val12 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val12
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6MatrixD2Ev(ptr noundef nonnull returned align 4 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #1 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.Matrix, ptr %this1, i32 0, i32 0
  %array.begin = getelementptr inbounds [1 x [2 x %struct.Item]], ptr %elements, i32 0, i32 0, i32 0
  %0 = getelementptr inbounds %struct.Item, ptr %array.begin, i64 2
  br label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %entry
  %arraydestroy.elementPast = phi ptr [ %0, %entry ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Item, ptr %arraydestroy.elementPast, i64 -1
  %call = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %array.begin
  br i1 %arraydestroy.done, label %arraydestroy.done2, label %arraydestroy.body

arraydestroy.done2:                               ; preds = %arraydestroy.body
  %1 = load ptr, ptr %retval, align 8
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN9ZeroArrayC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(1) %this, ptr noundef nonnull align 4 dereferenceable(1) %0) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN9ZeroArrayD2Ev(ptr noundef nonnull returned align 4 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %elements = getelementptr inbounds nuw %struct.ZeroArray, ptr %this1, i32 0, i32 0
  %array.begin = getelementptr inbounds [0 x %struct.Item], ptr %elements, i32 0, i32 0
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN10ZeroMatrixC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(1) %this, ptr noundef nonnull align 4 dereferenceable(1) %0) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN10ZeroMatrixD2Ev(ptr noundef nonnull returned align 4 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %elements = getelementptr inbounds nuw %struct.ZeroMatrix, ptr %this1, i32 0, i32 0
  %array.begin = getelementptr inbounds [3 x [0 x %struct.Item]], ptr %elements, i32 0, i32 0, i32 0
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5EmptyC2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5EmptyD2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN9EmptyPairC2ERKS_(ptr noundef nonnull returned align 1 dereferenceable(2) %this, ptr noundef nonnull align 1 dereferenceable(2) %0) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.EmptyPair, ptr %this1, i32 0, i32 0
  %1 = load ptr, ptr %.addr, align 8, !nonnull !5
  %elements2 = getelementptr inbounds nuw %struct.EmptyPair, ptr %1, i32 0, i32 0
  %arrayinit.begin = getelementptr inbounds [2 x %struct.Empty], ptr %elements, i64 0, i64 0
  br label %arrayinit.body

arrayinit.body:                                   ; preds = %invoke.cont, %entry
  %arrayinit.index = phi i64 [ 0, %entry ], [ %arrayinit.next, %invoke.cont ]
  %2 = getelementptr inbounds %struct.Empty, ptr %arrayinit.begin, i64 %arrayinit.index
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Empty], ptr %elements2, i64 0, i64 %arrayinit.index
  %call = invoke noundef ptr @_ZN5EmptyC1ERKS_(ptr noundef nonnull align 1 dereferenceable(1) %2, ptr noundef nonnull align 1 dereferenceable(1) %arrayidx)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %arrayinit.body
  %arrayinit.next = add nuw i64 %arrayinit.index, 1
  %arrayinit.done = icmp eq i64 %arrayinit.next, 2
  br i1 %arrayinit.done, label %arrayinit.end, label %arrayinit.body

arrayinit.end:                                    ; preds = %invoke.cont
  %3 = load ptr, ptr %retval, align 8
  ret ptr %3

lpad:                                             ; preds = %arrayinit.body
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot, align 4
  %arraydestroy.isempty = icmp eq ptr %arrayinit.begin, %2
  br i1 %arraydestroy.isempty, label %arraydestroy.done4, label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %lpad
  %arraydestroy.elementPast = phi ptr [ %2, %lpad ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Empty, ptr %arraydestroy.elementPast, i64 -1
  %call3 = call noundef ptr @_ZN5EmptyD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %arrayinit.begin
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
define linkonce_odr noundef ptr @_ZN5EmptyC1ERKS_(ptr noundef nonnull returned align 1 dereferenceable(1) %this, ptr noundef nonnull align 1 dereferenceable(1) %other) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %other, ptr %other.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %other.addr, align 8
  %call = call noundef ptr @_ZN5EmptyC2ERKS_(ptr noundef nonnull align 1 dereferenceable(1) %this1, ptr noundef nonnull align 1 dereferenceable(1) %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5EmptyC2ERKS_(ptr noundef nonnull returned align 1 dereferenceable(1) %this, ptr noundef nonnull align 1 dereferenceable(1) %other) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %other, ptr %other.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN9EmptyPairD2Ev(ptr noundef nonnull returned align 1 dead_on_return(2) dereferenceable(2) %this) unnamed_addr #1 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.EmptyPair, ptr %this1, i32 0, i32 0
  %array.begin = getelementptr inbounds [2 x %struct.Empty], ptr %elements, i32 0, i32 0
  %0 = getelementptr inbounds %struct.Empty, ptr %array.begin, i64 2
  br label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %entry
  %arraydestroy.elementPast = phi ptr [ %0, %entry ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Empty, ptr %arraydestroy.elementPast, i64 -1
  %call = call noundef ptr @_ZN5EmptyD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %array.begin
  br i1 %arraydestroy.done, label %arraydestroy.done2, label %arraydestroy.body

arraydestroy.done2:                               ; preds = %arraydestroy.body
  %1 = load ptr, ptr %retval, align 8
  ret ptr %1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN10HolderPairC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.HolderPair, ptr %this1, i32 0, i32 0
  %1 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements2 = getelementptr inbounds nuw %struct.HolderPair, ptr %1, i32 0, i32 0
  %arrayinit.begin = getelementptr inbounds [2 x %struct.Holder], ptr %elements, i64 0, i64 0
  br label %arrayinit.body

arrayinit.body:                                   ; preds = %invoke.cont, %entry
  %arrayinit.index = phi i64 [ 0, %entry ], [ %arrayinit.next, %invoke.cont ]
  %2 = getelementptr inbounds %struct.Holder, ptr %arrayinit.begin, i64 %arrayinit.index
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Holder], ptr %elements2, i64 0, i64 %arrayinit.index
  %call = invoke noundef ptr @_ZN6HolderC1ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %arrayinit.body
  %arrayinit.next = add nuw i64 %arrayinit.index, 1
  %arrayinit.done = icmp eq i64 %arrayinit.next, 2
  br i1 %arrayinit.done, label %arrayinit.end, label %arrayinit.body

arrayinit.end:                                    ; preds = %invoke.cont
  %3 = load ptr, ptr %retval, align 8
  ret ptr %3

lpad:                                             ; preds = %arrayinit.body
  %4 = landingpad { ptr, i32 }
          cleanup
  %5 = extractvalue { ptr, i32 } %4, 0
  store ptr %5, ptr %exn.slot, align 8
  %6 = extractvalue { ptr, i32 } %4, 1
  store i32 %6, ptr %ehselector.slot, align 4
  %arraydestroy.isempty = icmp eq ptr %arrayinit.begin, %2
  br i1 %arraydestroy.isempty, label %arraydestroy.done4, label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %lpad
  %arraydestroy.elementPast = phi ptr [ %2, %lpad ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Holder, ptr %arraydestroy.elementPast, i64 -1
  %call3 = call noundef ptr @_ZN6HolderD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %arrayinit.begin
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
define linkonce_odr noundef ptr @_ZN6HolderC1ERKS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %call = call noundef ptr @_ZN6HolderC2ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6HolderD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN6HolderD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6HolderC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %storage = getelementptr inbounds nuw %struct.Holder, ptr %this1, i32 0, i32 0
  store i8 0, ptr %storage, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6HolderD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %items = getelementptr inbounds nuw %struct.Holder, ptr %this1, i32 0, i32 1
  %array.begin = getelementptr inbounds [0 x %struct.Item], ptr %items, i32 0, i32 0
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN10HolderPairD2Ev(ptr noundef nonnull returned align 4 dead_on_return(8) dereferenceable(8) %this) unnamed_addr #1 {
entry:
  %retval = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store ptr %this1, ptr %retval, align 8
  %elements = getelementptr inbounds nuw %struct.HolderPair, ptr %this1, i32 0, i32 0
  %array.begin = getelementptr inbounds [2 x %struct.Holder], ptr %elements, i32 0, i32 0
  %0 = getelementptr inbounds %struct.Holder, ptr %array.begin, i64 2
  br label %arraydestroy.body

arraydestroy.body:                                ; preds = %arraydestroy.body, %entry
  %arraydestroy.elementPast = phi ptr [ %0, %entry ], [ %arraydestroy.element, %arraydestroy.body ]
  %arraydestroy.element = getelementptr inbounds %struct.Holder, ptr %arraydestroy.elementPast, i64 -1
  %call = call noundef ptr @_ZN6HolderD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %arraydestroy.element) #2
  %arraydestroy.done = icmp eq ptr %arraydestroy.element, %array.begin
  br i1 %arraydestroy.done, label %arraydestroy.done2, label %arraydestroy.body

arraydestroy.done2:                               ; preds = %arraydestroy.body
  %1 = load ptr, ptr %retval, align 8
  ret ptr %1
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
!5 = !{}
!6 = !{i64 4}
