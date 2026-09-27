; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names operator_results.cpp -o -
; ModuleID = 'operator_results.cpp'
source_filename = "operator_results.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Number = type { i32 }
%struct.Big = type { [3 x i64] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_ZpsR6Number(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  ret ptr %value1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_ZngO6Number(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i32 @_ZplRK6NumberS1_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %retval = alloca %struct.Number, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %value = getelementptr inbounds nuw %struct.Number, ptr %retval, i32 0, i32 0
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %value2 = getelementptr inbounds nuw %struct.Number, ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value2, align 4
  %add = add nsw i32 %1, %3
  store i32 %add, ptr %value, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.Number, ptr %retval, i32 0, i32 0
  %4 = load i32, ptr %coerce.dive, align 4
  ret i32 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_ZplRK3BigS1_(ptr dead_on_unwind noalias writable sret(%struct.Big) align 8 %agg.result, ptr noundef nonnull align 8 dereferenceable(24) %left, ptr noundef nonnull align 8 dereferenceable(24) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.result, ptr align 8 %0, i64 24, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_ZntR6Number(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  store i32 0, ptr %value1, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6AssignR6Number(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZpsR6Number(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 7, ptr %call, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @_ZntR6Number(ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z4MoveR6Number(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZngO6Number(ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5SmallRK6NumberS1_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %ref.tmp = alloca %struct.Number, align 4
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call = call i32 @_ZplRK6NumberS1_(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %coerce.dive = getelementptr inbounds nuw %struct.Number, ptr %ref.tmp, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %value = getelementptr inbounds nuw %struct.Number, ptr %ref.tmp, i32 0, i32 0
  %2 = load i32, ptr %value, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5LargeRK3BigS1_(ptr dead_on_unwind noalias writable sret(%struct.Big) align 8 %agg.result, ptr noundef nonnull align 8 dereferenceable(24) %left, ptr noundef nonnull align 8 dereferenceable(24) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %1 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !7
  call void @_ZplRK3BigS1_(ptr dead_on_unwind writable sret(%struct.Big) align 8 %agg.result, ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %1)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7DiscardRK3BigS1_(ptr noundef nonnull align 8 dereferenceable(24) %left, ptr noundef nonnull align 8 dereferenceable(24) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %tmp = alloca %struct.Big, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %1 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !7
  call void @_ZplRK3BigS1_(ptr dead_on_unwind writable sret(%struct.Big) align 8 %tmp, ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %1)
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }

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
