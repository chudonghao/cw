; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names multiple_inheritance_calls.cpp -o -
; ModuleID = 'multiple_inheritance_calls.cpp'
source_filename = "multiple_inheritance_calls.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Nothing = type { i8 }
%struct.Vector = type { %struct.X, %struct.Y, float }
%struct.X = type { float }
%struct.Y = type { float }
%struct.Links = type { %struct.Head, %struct.Tail }
%struct.Head = type { ptr }
%struct.Tail = type { ptr }
%struct.Marked = type { %struct.Head, ptr }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z11PassNothing7Nothing() #0 {
entry:
  %value = alloca %struct.Nothing, align 1
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define %struct.Vector @_Z10PassVector6Vector([3 x float] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Vector, align 4
  %value = alloca %struct.Vector, align 4
  store [3 x float] %value.coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %value, i64 12, i1 false)
  %0 = load %struct.Vector, ptr %retval, align 4
  ret %struct.Vector %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z9PassLinks5Links([2 x ptr] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Links, align 8
  %value = alloca %struct.Links, align 8
  store [2 x ptr] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %retval, align 8
  ret [2 x i64] %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z10PassMarked6Marked([2 x i64] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Marked, align 8
  %value = alloca %struct.Marked, align 8
  store [2 x i64] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %retval, align 8
  ret [2 x i64] %0
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 4]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.5"}
