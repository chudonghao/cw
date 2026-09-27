; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names aggregate_zero_size.cpp -o -
; ModuleID = 'aggregate_zero_size.cpp'
source_filename = "aggregate_zero_size.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Empty = type { i8 }
%struct.Aligned = type { [0 x i64] }
%struct.Value = type { [3 x i64] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z4MakeRi(ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z4Take5Emptya(i8 noundef signext %number) #0 {
entry:
  %value = alloca %struct.Empty, align 1
  %number.addr = alloca i8, align 1
  store i8 %number, ptr %number.addr, align 1
  %0 = load i8, ptr %number.addr, align 1
  ret i8 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z3UseRia(ptr noundef nonnull align 4 dereferenceable(4) %counter, i8 noundef signext %number) #0 {
entry:
  %counter.addr = alloca ptr, align 8
  %number.addr = alloca i8, align 1
  %value = alloca %struct.Empty, align 1
  %undef.agg.tmp = alloca %struct.Empty, align 1
  %agg.tmp = alloca %struct.Empty, align 1
  store ptr %counter, ptr %counter.addr, align 8
  store i8 %number, ptr %number.addr, align 1
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  call void @_Z4MakeRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load i8, ptr %number.addr, align 1
  %call = call noundef signext i8 @_Z4Take5Emptya(i8 noundef signext %1)
  ret i8 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z8Identity7Aligned() #0 {
entry:
  %retval = alloca %struct.Aligned, align 8
  %value = alloca %struct.Aligned, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 0, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z4FormRK7Aligned(ptr noundef nonnull align 8 dereferenceable(1) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %result = alloca %struct.Aligned, align 8
  %agg.tmp = alloca %struct.Aligned, align 8
  %undef.agg.tmp = alloca %struct.Aligned, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp, ptr align 8 %0, i64 0, i1 false)
  call void @_Z8Identity7Aligned()
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5Mixed5Emptyb5Valuea(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, i1 noundef zeroext %flag, ptr noundef align 8 dead_on_return %value, i8 noundef signext %number) #0 {
entry:
  %empty = alloca %struct.Empty, align 1
  %flag.addr = alloca i8, align 1
  %value.indirect_addr = alloca ptr, align 8
  %number.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %value, ptr %value.indirect_addr, align 8
  store i8 %number, ptr %number.addr, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7CombineRK5Valueba(ptr dead_on_unwind noalias writable sret(%struct.Value) align 8 %agg.result, ptr noundef nonnull align 8 dereferenceable(24) %value, i1 noundef zeroext %flag, i8 noundef signext %number) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %number.addr = alloca i8, align 1
  %agg.tmp = alloca %struct.Empty, align 1
  %agg.tmp1 = alloca %struct.Value, align 8
  store ptr %value, ptr %value.addr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i8 %number, ptr %number.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp1, ptr align 8 %1, i64 24, i1 false)
  %2 = load i8, ptr %number.addr, align 1
  call void @_Z5Mixed5Emptyb5Valuea(ptr dead_on_unwind writable sret(%struct.Value) align 8 %agg.result, i1 noundef zeroext %loadedv, ptr noundef align 8 dead_on_return %agg.tmp1, i8 noundef signext %2)
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
