; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names layout_classification.cpp -o -
; ModuleID = 'layout_classification.cpp'
source_filename = "layout_classification.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Floats = type { float, float }
%struct.WithZero = type { float, [0 x float] }
%struct.Pointer = type { ptr }
%struct.Pointers = type { [2 x ptr] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define %struct.Floats @_Z13FloatIdentity6Floats([2 x float] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Floats, align 4
  %value = alloca %struct.Floats, align 4
  store [2 x float] %value.coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %value, i64 8, i1 false)
  %0 = load %struct.Floats, ptr %retval, align 4
  ret %struct.Floats %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i32 @_Z12ZeroIdentity8WithZero(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.WithZero, align 4
  %value = alloca %struct.WithZero, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.WithZero, ptr %value, i32 0, i32 0
  %coerce.val.ii = trunc i64 %value.coerce to i32
  store i32 %coerce.val.ii, ptr %coerce.dive, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %value, i64 4, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.WithZero, ptr %retval, i32 0, i32 0
  %0 = load i32, ptr %coerce.dive1, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z15PointerIdentity7Pointer(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.Pointer, align 8
  %value = alloca %struct.Pointer, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.Pointer, ptr %value, i32 0, i32 0
  %coerce.val.ip = inttoptr i64 %value.coerce to ptr
  store ptr %coerce.val.ip, ptr %coerce.dive, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 8, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.Pointer, ptr %retval, i32 0, i32 0
  %0 = load ptr, ptr %coerce.dive1, align 8
  %coerce.val.pi = ptrtoint ptr %0 to i64
  ret i64 %coerce.val.pi
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z16PointersIdentity8Pointers([2 x ptr] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Pointers, align 8
  %value = alloca %struct.Pointers, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.Pointers, ptr %value, i32 0, i32 0
  store [2 x ptr] %value.coerce, ptr %coerce.dive, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 16, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.Pointers, ptr %retval, i32 0, i32 0
  %0 = load [2 x i64], ptr %coerce.dive1, align 8
  ret [2 x i64] %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z13ArrayIdentity8Pointers([2 x ptr] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Pointers, align 8
  %value = alloca %struct.Pointers, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.Pointers, ptr %value, i32 0, i32 0
  store [2 x ptr] %value.coerce, ptr %coerce.dive, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 16, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.Pointers, ptr %retval, i32 0, i32 0
  %0 = load [2 x i64], ptr %coerce.dive1, align 8
  ret [2 x i64] %0
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
