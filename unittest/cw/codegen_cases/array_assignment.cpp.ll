; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names array_assignment.cpp -o -
; ModuleID = 'array_assignment.cpp'
source_filename = "array_assignment.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Array = type { [2 x i32] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11CopyAndMoveRK5Arraym(ptr noundef nonnull align 4 dereferenceable(8) %source, i64 noundef %index) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %copied = alloca %struct.Array, align 4
  %moved = alloca %struct.Array, align 4
  store ptr %source, ptr %source.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %copied, ptr align 4 %0, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %copied, i64 8, i1 false)
  %1 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %1, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %moved, i64 8, i1 false)
  %values = getelementptr inbounds nuw %struct.Array, ptr %moved, i32 0, i32 0
  %2 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 %2
  %3 = load i32, ptr %arrayidx, align 4
  ret i32 %3
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_Z6AssignR5ArrayRKS_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 8, i1 false)
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5ChainR5ArrayS0_RKS_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %middle, ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %middle.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %middle, ptr %middle.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %middle.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 8, i1 false)
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %2, ptr align 4 %1, i64 8, i1 false)
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
