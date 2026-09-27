; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names string_arrays.cpp -o -
; ModuleID = 'string_arrays.cpp'
source_filename = "string_arrays.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Array = type { [3 x i8] }
%struct.EmptyArray = type { [0 x i8] }

@__const._Z4Copym.text = private unnamed_addr constant %struct.Array { [3 x i8] c"abc" }, align 1
@_ZL8Original = internal constant %struct.Array { [3 x i8] c"abc" }, align 1
@_ZL11Replacement = internal constant %struct.Array { [3 x i8] c"def" }, align 1
@_ZL12EmptyLiteral = internal constant %struct.EmptyArray zeroinitializer, align 1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z4Copym(i64 noundef %index) #0 {
entry:
  %index.addr = alloca i64, align 8
  %text = alloca %struct.Array, align 1
  store i64 %index, ptr %index.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %text, ptr align 1 @__const._Z4Copym.text, i64 3, i1 false)
  %values = getelementptr inbounds nuw %struct.Array, ptr %text, i32 0, i32 0
  %0 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [3 x i8], ptr %values, i64 0, i64 %0
  store i8 120, ptr %arrayidx, align 1
  %values1 = getelementptr inbounds nuw %struct.Array, ptr %text, i32 0, i32 0
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx2 = getelementptr inbounds nuw [3 x i8], ptr %values1, i64 0, i64 %1
  %2 = load i8, ptr %arrayidx2, align 1
  %conv = zext i8 %2 to i32
  %3 = load i64, ptr %index.addr, align 8
  %arrayidx3 = getelementptr inbounds nuw [3 x i8], ptr @_ZL8Original, i64 0, i64 %3
  %4 = load i8, ptr %arrayidx3, align 1
  %conv4 = zext i8 %4 to i32
  %add = add nsw i32 %conv, %conv4
  %conv5 = trunc i32 %add to i8
  ret i8 %conv5
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 1 dereferenceable(3) ptr @_Z6AssignR5Array(ptr noundef nonnull align 1 dereferenceable(3) %target) #0 {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %0, ptr align 1 @_ZL11Replacement, i64 3, i1 false)
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z5Emptyv() #0 {
entry:
  %text = alloca %struct.EmptyArray, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %text, ptr align 1 @_ZL12EmptyLiteral, i64 0, i1 false)
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
