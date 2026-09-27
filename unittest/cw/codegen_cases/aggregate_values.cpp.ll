; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names aggregate_values.cpp -o -
; ModuleID = 'aggregate_values.cpp'
source_filename = "aggregate_values.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Byte = type { i8 }
%struct.Odd = type { [3 x i8] }
%struct.Pair = type { i64, i64 }
%struct.Pointers = type { ptr, ptr }
%struct.Block = type { [3 x i64] }
%struct.NineBytes = type { [9 x i8] }
%struct.ThreeWords = type { [3 x i64] }
%struct.Booleans = type { [2 x i8] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i8 @_Z5Small4Byte(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.Byte, align 1
  %value = alloca %struct.Byte, align 1
  %coerce.dive = getelementptr inbounds nuw %struct.Byte, ptr %value, i32 0, i32 0
  %coerce.val.ii = trunc i64 %value.coerce to i8
  store i8 %coerce.val.ii, ptr %coerce.dive, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %retval, ptr align 1 %value, i64 1, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.Byte, ptr %retval, i32 0, i32 0
  %0 = load i8, ptr %coerce.dive1, align 1
  ret i8 %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i24 @_Z5Three3Odd(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.Odd, align 1
  %value = alloca %struct.Odd, align 1
  %coerce.dive1.coerce = alloca i24, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.Odd, ptr %value, i32 0, i32 0
  %coerce.val.ii = trunc i64 %value.coerce to i24
  store i24 %coerce.val.ii, ptr %coerce.dive, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %retval, ptr align 1 %value, i64 3, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.Odd, ptr %retval, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %coerce.dive1.coerce, ptr align 1 %coerce.dive1, i64 3, i1 false)
  %0 = load i24, ptr %coerce.dive1.coerce, align 4
  ret i24 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z8TwoWords4Pair([2 x i64] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Pair, align 8
  %value = alloca %struct.Pair, align 8
  store [2 x i64] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %retval, align 8
  ret [2 x i64] %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z9Addresses8Pointers([2 x ptr] %value.coerce) #0 {
entry:
  %retval = alloca %struct.Pointers, align 8
  %value = alloca %struct.Pointers, align 8
  store [2 x ptr] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %retval, align 8
  ret [2 x i64] %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z9Structure5Block(ptr dead_on_unwind noalias writable sret(%struct.Block) align 8 %agg.result, ptr noundef align 8 dead_on_return %value) #0 {
entry:
  %value.indirect_addr = alloca ptr, align 8
  store ptr %value, ptr %value.indirect_addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i24 @_Z9CopyThreeRK3Odd(ptr noundef nonnull align 1 dereferenceable(3) %value) #0 {
entry:
  %retval = alloca %struct.Odd, align 1
  %value.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.Odd, align 1
  %coerce.dive.coerce = alloca i64, align 8
  %coerce.dive2.coerce = alloca i24, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %agg.tmp, ptr align 1 %0, i64 3, i1 false)
  %coerce.dive = getelementptr inbounds nuw %struct.Odd, ptr %agg.tmp, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce.dive.coerce, ptr align 1 %coerce.dive, i64 3, i1 false)
  %1 = load i64, ptr %coerce.dive.coerce, align 8
  %call = call i24 @_Z5Three3Odd(i64 %1)
  %coerce.dive1 = getelementptr inbounds nuw %struct.Odd, ptr %retval, i32 0, i32 0
  store i24 %call, ptr %coerce.dive1, align 1
  %coerce.dive2 = getelementptr inbounds nuw %struct.Odd, ptr %retval, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %coerce.dive2.coerce, ptr align 1 %coerce.dive2, i64 3, i1 false)
  %2 = load i24, ptr %coerce.dive2.coerce, align 4
  ret i24 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z4Nine9NineBytes([2 x i64] %value.coerce) #0 {
entry:
  %retval = alloca %struct.NineBytes, align 1
  %value = alloca %struct.NineBytes, align 1
  %tmp.coerce = alloca [2 x i64], align 8
  %coerce.dive1.coerce = alloca [2 x i64], align 8
  %coerce.dive = getelementptr inbounds nuw %struct.NineBytes, ptr %value, i32 0, i32 0
  store [2 x i64] %value.coerce, ptr %tmp.coerce, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %coerce.dive, ptr align 8 %tmp.coerce, i64 9, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %retval, ptr align 1 %value, i64 9, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.NineBytes, ptr %retval, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce.dive1.coerce, ptr align 1 %coerce.dive1, i64 9, i1 false)
  %0 = load [2 x i64], ptr %coerce.dive1.coerce, align 8
  ret [2 x i64] %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5Large10ThreeWords(ptr dead_on_unwind noalias writable sret(%struct.ThreeWords) align 8 %agg.result, ptr noundef align 8 dead_on_return %value) #0 {
entry:
  %value.indirect_addr = alloca ptr, align 8
  store ptr %value, ptr %value.indirect_addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i16 @_Z7Boolean8Booleans(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.Booleans, align 1
  %value = alloca %struct.Booleans, align 1
  %coerce.dive = getelementptr inbounds nuw %struct.Booleans, ptr %value, i32 0, i32 0
  %coerce.val.ii = trunc i64 %value.coerce to i16
  store i16 %coerce.val.ii, ptr %coerce.dive, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %retval, ptr align 1 %value, i64 2, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.Booleans, ptr %retval, i32 0, i32 0
  %0 = load i16, ptr %coerce.dive1, align 1
  ret i16 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z8CopyNineRK9NineBytes(ptr noundef nonnull align 1 dereferenceable(9) %value) #0 {
entry:
  %retval = alloca %struct.NineBytes, align 1
  %value.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.NineBytes, align 1
  %coerce.dive.coerce = alloca [2 x i64], align 8
  %tmp.coerce = alloca [2 x i64], align 8
  %coerce.dive2.coerce = alloca [2 x i64], align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %agg.tmp, ptr align 1 %0, i64 9, i1 false)
  %coerce.dive = getelementptr inbounds nuw %struct.NineBytes, ptr %agg.tmp, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce.dive.coerce, ptr align 1 %coerce.dive, i64 9, i1 false)
  %1 = load [2 x i64], ptr %coerce.dive.coerce, align 8
  %call = call [2 x i64] @_Z4Nine9NineBytes([2 x i64] %1)
  %coerce.dive1 = getelementptr inbounds nuw %struct.NineBytes, ptr %retval, i32 0, i32 0
  store [2 x i64] %call, ptr %tmp.coerce, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %coerce.dive1, ptr align 8 %tmp.coerce, i64 9, i1 false)
  %coerce.dive2 = getelementptr inbounds nuw %struct.NineBytes, ptr %retval, i32 0, i32 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce.dive2.coerce, ptr align 1 %coerce.dive2, i64 9, i1 false)
  %2 = load [2 x i64], ptr %coerce.dive2.coerce, align 8
  ret [2 x i64] %2
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
