; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names aggregate_indirect_evaluation.cpp -o -
; ModuleID = 'aggregate_indirect_evaluation.cpp'
source_filename = "aggregate_indirect_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Value = type { [3 x i64] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5Other5Valuei(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, ptr noundef align 8 dead_on_return %value, i32 noundef %ignored) #0 {
entry:
  %value.indirect_addr = alloca ptr, align 8
  %ignored.addr = alloca i32, align 4
  store ptr %value, ptr %value.indirect_addr, align 8
  store i32 %ignored, ptr %ignored.addr, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7ReplaceRPF5ValueS_iE(ptr noundef nonnull align 8 dereferenceable(8) %callback) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8, !nonnull !5, !align !6
  store ptr @_Z5Other5Valuei, ptr %0, align 8
  ret i32 0
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6InvokeRPF5ValueS_iERKS_(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, ptr noundef nonnull align 8 dereferenceable(8) %callback, ptr noundef nonnull align 8 dereferenceable(24) %value) #2 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %callee = alloca ptr, align 8
  %argument = alloca %struct.Value, align 8
  %ignored = alloca i32, align 4
  %agg.tmp = alloca %struct.Value, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %0, align 8
  store ptr %1, ptr %callee, align 8
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %2, i64 24, i1 false)
  %3 = load ptr, ptr %callback.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z7ReplaceRPF5ValueS_iE(ptr noundef nonnull align 8 dereferenceable(8) %3)
  store i32 %call, ptr %ignored, align 4
  %4 = load ptr, ptr %callee, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp, ptr align 8 %argument, i64 24, i1 false)
  %5 = load i32, ptr %ignored, align 4
  call void %4(ptr dead_on_unwind writable sret(%struct.Value) align 8 %agg.result, ptr noundef align 8 dead_on_return %agg.tmp, i32 noundef %5)
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 8}
