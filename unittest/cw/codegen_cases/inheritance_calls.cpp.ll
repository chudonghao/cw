; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names inheritance_calls.cpp -o -
; ModuleID = 'inheritance_calls.cpp'
source_filename = "inheritance_calls.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Floats = type { %struct.FloatBase, double }
%struct.FloatBase = type { double }
%struct.BigBase = type { [3 x i64] }
%struct.Big = type <{ %struct.BigBase, i8, [7 x i8] }>

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define %struct.Floats @_Z13FloatIdentity6Floats([2 x double] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Floats, align 8
  %value = alloca %struct.Floats, align 8
  store [2 x double] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 16, i1 false)
  %0 = load %struct.Floats, ptr %retval, align 8
  ret %struct.Floats %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define %struct.Floats @_Z9FloatCallRK6Floats(ptr noundef nonnull align 8 dereferenceable(16) %value) #0 {
entry:
  %retval = alloca %struct.Floats, align 8
  %value.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.Floats, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp, ptr align 8 %0, i64 16, i1 false)
  %1 = load [2 x double], ptr %agg.tmp, align 8
  %call = call %struct.Floats @_Z13FloatIdentity6Floats([2 x double] %1)
  %2 = getelementptr inbounds nuw %struct.Floats, ptr %retval, i32 0, i32 0
  %3 = extractvalue %struct.Floats %call, 0
  store %struct.FloatBase %3, ptr %2, align 8
  %4 = getelementptr inbounds nuw %struct.Floats, ptr %retval, i32 0, i32 1
  %5 = extractvalue %struct.Floats %call, 1
  store double %5, ptr %4, align 8
  %6 = load %struct.Floats, ptr %retval, align 8
  ret %struct.Floats %6
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z11MakeBigBasev(ptr dead_on_unwind noalias writable sret(%struct.BigBase) align 8 %agg.result) #0 {
entry:
  call void @llvm.memset.p0.i64(ptr align 8 %agg.result, i8 0, i64 24, i1 false)
  %values = getelementptr inbounds nuw %struct.BigBase, ptr %agg.result, i32 0, i32 0
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #2

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7BigCallv(ptr dead_on_unwind noalias writable sret(%struct.Big) align 8 %agg.result) #0 {
entry:
  %ref.tmp = alloca %struct.BigBase, align 8
  call void @_Z11MakeBigBasev(ptr dead_on_unwind writable sret(%struct.BigBase) align 8 %ref.tmp)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.result, ptr align 8 %ref.tmp, i64 24, i1 false)
  %flag = getelementptr inbounds nuw %struct.Big, ptr %agg.result, i32 0, i32 1
  store i8 1, ptr %flag, align 8
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z8IndirectPF3BigS_ERKS_(ptr dead_on_unwind noalias writable sret(%struct.Big) align 8 %agg.result, ptr noundef %callback, ptr noundef nonnull align 8 dereferenceable(25) %value) #3 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.Big, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp, ptr align 8 %1, i64 32, i1 false)
  call void %0(ptr dead_on_unwind writable sret(%struct.Big) align 8 %agg.result, ptr noundef align 8 dead_on_return %agg.tmp)
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #3 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 8}
