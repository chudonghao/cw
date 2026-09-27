; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names inheritance_operations.cpp -o -
; ModuleID = 'inheritance_operations.cpp'
source_filename = "inheritance_operations.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Base = type <{ %struct.Root, i8, [3 x i8] }>
%struct.Root = type { i32 }
%struct.Derived = type { %struct.Base.base, i8, [2 x i8] }
%struct.Base.base = type <{ %struct.Root, i8 }>
%struct.Array = type { [2 x %struct.Derived] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z4Makei(i32 noundef %seed) #0 {
entry:
  %retval = alloca %struct.Base, align 4
  %seed.addr = alloca i32, align 4
  store i32 %seed, ptr %seed.addr, align 4
  %number = getelementptr inbounds nuw %struct.Root, ptr %retval, i32 0, i32 0
  %0 = load i32, ptr %seed.addr, align 4
  store i32 %0, ptr %number, align 4
  %tag = getelementptr inbounds nuw %struct.Base, ptr %retval, i32 0, i32 1
  store i8 9, ptr %tag, align 4
  %1 = load i64, ptr %retval, align 4
  ret i64 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z4Formi(i32 noundef %seed) #0 {
entry:
  %retval = alloca %struct.Derived, align 4
  %seed.addr = alloca i32, align 4
  %ref.tmp = alloca %struct.Base, align 4
  store i32 %seed, ptr %seed.addr, align 4
  %0 = load i32, ptr %seed.addr, align 4
  %call = call i64 @_Z4Makei(i32 noundef %0)
  %coerce.val.ii = trunc i64 %call to i40
  store i40 %coerce.val.ii, ptr %ref.tmp, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %ref.tmp, i64 5, i1 false)
  %own = getelementptr inbounds nuw %struct.Derived, ptr %retval, i32 0, i32 1
  store i8 7, ptr %own, align 1
  %1 = load i64, ptr %retval, align 4
  ret i64 %1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z6AssignR7DerivedRK4Base(ptr noundef nonnull align 4 dereferenceable(6) %target, ptr noundef nonnull align 4 dereferenceable(5) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %base = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  store ptr %0, ptr %base, align 8
  %1 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %2 = load ptr, ptr %base, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %2, ptr align 4 %1, i64 5, i1 false)
  %3 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %own = getelementptr inbounds nuw %struct.Derived, ptr %3, i32 0, i32 1
  %4 = load i8, ptr %own, align 1
  ret i8 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define [2 x i64] @_Z4CopyRK5Array(ptr noundef nonnull align 4 dereferenceable(16) %source) #0 {
entry:
  %retval = alloca %struct.Array, align 4
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %0, i64 16, i1 false)
  %coerce.dive = getelementptr inbounds nuw %struct.Array, ptr %retval, i32 0, i32 0
  %1 = load [2 x i64], ptr %coerce.dive, align 4
  ret [2 x i64] %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z7Defaultv() #0 {
entry:
  %retval = alloca %struct.Derived, align 4
  %ref.tmp = alloca %struct.Base, align 4
  %number = getelementptr inbounds nuw %struct.Root, ptr %ref.tmp, i32 0, i32 0
  store i32 0, ptr %number, align 4
  %tag = getelementptr inbounds nuw %struct.Base, ptr %ref.tmp, i32 0, i32 1
  store i8 0, ptr %tag, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %retval, ptr align 4 %ref.tmp, i64 5, i1 false)
  %own = getelementptr inbounds nuw %struct.Derived, ptr %retval, i32 0, i32 1
  store i8 7, ptr %own, align 1
  %0 = load i64, ptr %retval, align 4
  ret i64 %0
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
