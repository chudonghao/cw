; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names aggregate_calls.cpp -o -
; ModuleID = 'aggregate_calls.cpp'
source_filename = "aggregate_calls.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Value = type { [3 x i64] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z4MakeaRi(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  %values = getelementptr inbounds nuw %struct.Value, ptr %agg.result, i32 0, i32 0
  %3 = load i8, ptr %value.addr, align 1
  %conv = sext i8 %3 to i64
  store i64 %conv, ptr %values, align 8
  %arrayinit.element = getelementptr inbounds i64, ptr %values, i64 1
  store i64 2, ptr %arrayinit.element, align 8
  %arrayinit.element1 = getelementptr inbounds i64, ptr %values, i64 2
  store i64 3, ptr %arrayinit.element1, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7ForwardaRi(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  call void @_Z4MakeaRi(ptr dead_on_unwind writable sret(%struct.Value) align 8 %agg.result, i8 noundef signext %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z8IndirectPF5ValueaRiEaS0_(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, ptr noundef %callback, i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #1 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i8, ptr %value.addr, align 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  call void %0(ptr dead_on_unwind writable sret(%struct.Value) align 8 %agg.result, i8 noundef signext %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7DiscardaRi(i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  %tmp = alloca %struct.Value, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  call void @_Z4MakeaRi(ptr dead_on_unwind writable sret(%struct.Value) align 8 %tmp, i8 noundef signext %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z7ElementaRim(i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter, i64 noundef %index) #0 {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %ref.tmp = alloca %struct.Value, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  call void @_Z4MakeaRi(ptr dead_on_unwind writable sret(%struct.Value) align 8 %ref.tmp, i8 noundef signext %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %values = getelementptr inbounds nuw %struct.Value, ptr %ref.tmp, i32 0, i32 0
  %2 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [3 x i64], ptr %values, i64 0, i64 %2
  %3 = load i64, ptr %arrayidx, align 8
  ret i64 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(24) ptr @_Z9ReferenceR5Value(ptr noundef nonnull align 8 dereferenceable(24) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z13CopyReferenceR5Value(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, ptr noundef nonnull align 8 dereferenceable(24) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %call = call noundef nonnull align 8 dereferenceable(24) ptr @_Z9ReferenceR5Value(ptr noundef nonnull align 8 dereferenceable(24) %0)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.result, ptr align 8 %call, i64 24, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z8Identity5Value(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, ptr noundef align 8 dead_on_return %value) #0 {
entry:
  %value.indirect_addr = alloca ptr, align 8
  store ptr %value, ptr %value.indirect_addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6NestedaRi(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.Value, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  call void @_Z4MakeaRi(ptr dead_on_unwind writable sret(%struct.Value) align 8 %agg.tmp, i8 noundef signext %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  call void @_Z8Identity5Value(ptr dead_on_unwind writable sret(%struct.Value) align 8 %agg.result, ptr noundef align 8 dead_on_return %agg.tmp)
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
!7 = !{i64 8}
