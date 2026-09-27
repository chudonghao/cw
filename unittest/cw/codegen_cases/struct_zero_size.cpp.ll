; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names struct_zero_size.cpp -o -
; ModuleID = 'struct_zero_size.cpp'
source_filename = "struct_zero_size.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Aligned = type { [0 x i64] }
%struct.Empty = type { i8 }
%struct.Wrapper = type { [8 x i8], %struct.Aligned, [2 x %struct.Empty] }
%struct.Mixed = type { i8, %struct.Aligned, i8 }
%struct.LargeValue = type { [0 x %struct.Aligned] }

@__const._Z4Zerom.object = private unnamed_addr constant { [8 x i8], %struct.Aligned, <{ %struct.Empty, %struct.Empty }> } { [8 x i8] undef, %struct.Aligned zeroinitializer, <{ %struct.Empty, %struct.Empty }> undef }, align 8
@__const._Z4Zerom.many = private unnamed_addr constant [2 x %struct.Empty] undef, align 1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z4Zerom(i64 noundef %index) #0 {
entry:
  %index.addr = alloca i64, align 8
  %object = alloca %struct.Wrapper, align 8
  %copied = alloca %struct.Wrapper, align 8
  %many = alloca [2 x %struct.Empty], align 1
  %reference = alloca ptr, align 8
  store i64 %index, ptr %index.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %object, ptr align 8 @__const._Z4Zerom.object, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %copied, ptr align 8 %object, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %copied, ptr align 8 %object, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %many, ptr align 1 @__const._Z4Zerom.many, i64 2, i1 false)
  %0 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Empty], ptr %many, i64 0, i64 %0
  store ptr %arrayidx, ptr %reference, align 8
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5StoreR5Mixed(ptr noundef nonnull align 8 dereferenceable(16) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %tail = getelementptr inbounds nuw %struct.Mixed, ptr %0, i32 0, i32 2
  store i8 1, ptr %tail, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(1) ptr @_Z7ForwardR7AlignedRi(ptr noundef nonnull align 8 dereferenceable(1) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6AssignR7AlignedS0_Ri(ptr noundef nonnull align 8 dereferenceable(1) %source, ptr noundef nonnull align 8 dereferenceable(1) %target, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  %call = call noundef nonnull align 8 dereferenceable(1) ptr @_Z7ForwardR7AlignedRi(ptr noundef nonnull align 8 dereferenceable(1) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  %call1 = call noundef nonnull align 8 dereferenceable(1) ptr @_Z7ForwardR7AlignedRi(ptr noundef nonnull align 8 dereferenceable(1) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %call1, ptr align 8 %call, i64 0, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5LargeRK10LargeValue(ptr noundef nonnull align 8 dereferenceable(1) %source) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %copied = alloca %struct.LargeValue, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %copied, ptr align 8 %0, i64 0, i1 false)
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
!6 = !{i64 8}
!7 = !{i64 4}
