; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names array_zero_size.cpp -o -
; ModuleID = 'array_zero_size.cpp'
source_filename = "array_zero_size.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Empty = type { [0 x i32] }
%struct.LargeArray = type { [18446744073709551615 x [0 x i32]] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(1) ptr @_Z7ForwardR5Empty(ptr noundef nonnull align 4 dereferenceable(1) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6AssignR5EmptyS0_(ptr noundef nonnull align 4 dereferenceable(1) %source, ptr noundef nonnull align 4 dereferenceable(1) %target) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(1) ptr @_Z7ForwardR5Empty(ptr noundef nonnull align 4 dereferenceable(1) %0)
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef nonnull align 4 dereferenceable(1) ptr @_Z7ForwardR5Empty(ptr noundef nonnull align 4 dereferenceable(1) %1)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call1, ptr align 4 %call, i64 0, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z5IndexRm(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = load i64, ptr %0, align 8
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %3 = load i64, ptr %2, align 8
  %add = add i64 %1, %3
  %4 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  store i64 %add, ptr %4, align 8
  %5 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %6 = load i64, ptr %5, align 8
  %7 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %8 = load i64, ptr %7, align 8
  %sub = sub i64 %6, %8
  ret i64 %sub
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6NestedRm(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %values = alloca [2 x %struct.Empty], align 4
  %copied = alloca %struct.Empty, align 4
  %ref.tmp = alloca %struct.Empty, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %call = call noundef i64 @_Z5IndexRm(ptr noundef nonnull align 8 dereferenceable(8) %0)
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Empty], ptr %values, i64 0, i64 %call
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %copied, ptr align 4 %arrayidx, i64 0, i1 false)
  %values1 = getelementptr inbounds nuw %struct.Empty, ptr %ref.tmp, i32 0, i32 0
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %call2 = call noundef i64 @_Z5IndexRm(ptr noundef nonnull align 8 dereferenceable(8) %1)
  %arrayidx3 = getelementptr inbounds nuw [2 x %struct.Empty], ptr %values, i64 0, i64 %call2
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %arrayidx3, ptr align 4 %ref.tmp, i64 0, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5LargeRK10LargeArray(ptr noundef nonnull align 4 dereferenceable(1) %source) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %copied = alloca %struct.LargeArray, align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %copied, ptr align 4 %0, i64 0, i1 false)
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
