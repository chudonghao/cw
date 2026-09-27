; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names aggregate_floats.cpp -o -
; ModuleID = 'aggregate_floats.cpp'
source_filename = "aggregate_floats.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Homogeneous = type { %struct.Inner, [2 x float] }
%struct.Inner = type { float }
%struct.FourDoubles = type { [4 x double] }
%struct.FiveFloats = type { [5 x float] }
%struct.Mixed = type { float, i32 }
%struct.Padded = type { float, [0 x i64] }
%struct.ZeroArray = type { double, [0 x i64] }
%struct.NestedZeroArray = type { float, [2 x [0 x i32]] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define %struct.Homogeneous @_Z6Nested11Homogeneous([3 x float] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Homogeneous, align 4
  %value = alloca %struct.Homogeneous, align 4
  store [3 x float] %value.coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %value, i64 12, i1 false)
  %0 = load %struct.Homogeneous, ptr %retval, align 4
  ret %struct.Homogeneous %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define %struct.FourDoubles @_Z4Four11FourDoubles([4 x double] %value.coerce) #0 {
entry:
  %retval = alloca %struct.FourDoubles, align 8
  %value = alloca %struct.FourDoubles, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.FourDoubles, ptr %value, i32 0, i32 0
  store [4 x double] %value.coerce, ptr %coerce.dive, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 32, i1 false)
  %0 = load %struct.FourDoubles, ptr %retval, align 8
  ret %struct.FourDoubles %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z4Five10FiveFloats(ptr dead_on_unwind noalias writable sret(%struct.FiveFloats) align 4 %agg.result, ptr noundef align 4 dead_on_return %value) #0 {
entry:
  %value.indirect_addr = alloca ptr, align 8
  store ptr %value, ptr %value.indirect_addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.result, ptr align 4 %value, i64 20, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z9Different5Mixed(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.Mixed, align 4
  %value = alloca %struct.Mixed, align 4
  store i64 %value.coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %value, i64 8, i1 false)
  %0 = load i64, ptr %retval, align 4
  ret i64 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z11WithPadding6Padded(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.Padded, align 8
  %value = alloca %struct.Padded, align 8
  store i64 %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 8, i1 false)
  %0 = load i64, ptr %retval, align 8
  ret i64 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z13WithZeroArray9ZeroArray(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.ZeroArray, align 8
  %value = alloca %struct.ZeroArray, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.ZeroArray, ptr %value, i32 0, i32 0
  store i64 %value.coerce, ptr %coerce.dive, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 8, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.ZeroArray, ptr %retval, i32 0, i32 0
  %0 = load i64, ptr %coerce.dive1, align 8
  ret i64 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i32 @_Z19WithNestedZeroArray15NestedZeroArray(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.NestedZeroArray, align 4
  %value = alloca %struct.NestedZeroArray, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.NestedZeroArray, ptr %value, i32 0, i32 0
  %coerce.val.ii = trunc i64 %value.coerce to i32
  store i32 %coerce.val.ii, ptr %coerce.dive, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %value, i64 4, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.NestedZeroArray, ptr %retval, i32 0, i32 0
  %0 = load i32, ptr %coerce.dive1, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define %struct.Homogeneous @_Z7ForwardRK11Homogeneous(ptr noundef nonnull align 4 dereferenceable(12) %value) #0 {
entry:
  %retval = alloca %struct.Homogeneous, align 4
  %value.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.Homogeneous, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.tmp, ptr align 4 %0, i64 12, i1 false)
  %1 = load [3 x float], ptr %agg.tmp, align 4
  %call = call %struct.Homogeneous @_Z6Nested11Homogeneous([3 x float] %1)
  %2 = getelementptr inbounds nuw %struct.Homogeneous, ptr %retval, i32 0, i32 0
  %3 = extractvalue %struct.Homogeneous %call, 0
  store %struct.Inner %3, ptr %2, align 4
  %4 = getelementptr inbounds nuw %struct.Homogeneous, ptr %retval, i32 0, i32 1
  %5 = extractvalue %struct.Homogeneous %call, 1
  store [2 x float] %5, ptr %4, align 4
  %6 = load %struct.Homogeneous, ptr %retval, align 4
  ret %struct.Homogeneous %6
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z16ForwardZeroArrayRK9ZeroArray(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %retval = alloca %struct.ZeroArray, align 8
  %value.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.ZeroArray, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp, ptr align 8 %0, i64 8, i1 false)
  %coerce.dive = getelementptr inbounds nuw %struct.ZeroArray, ptr %agg.tmp, i32 0, i32 0
  %1 = load i64, ptr %coerce.dive, align 8
  %call = call i64 @_Z13WithZeroArray9ZeroArray(i64 %1)
  %coerce.dive1 = getelementptr inbounds nuw %struct.ZeroArray, ptr %retval, i32 0, i32 0
  store i64 %call, ptr %coerce.dive1, align 8
  %coerce.dive2 = getelementptr inbounds nuw %struct.ZeroArray, ptr %retval, i32 0, i32 0
  %2 = load i64, ptr %coerce.dive2, align 8
  ret i64 %2
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
