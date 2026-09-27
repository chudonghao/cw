; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names inheritance_zero_size.cpp -o -
; ModuleID = 'inheritance_zero_size.cpp'
source_filename = "inheritance_zero_size.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.ZeroDerived = type { [8 x i8] }
%struct.ZeroBase = type { [0 x i64] }
%struct.Occupied = type { %struct.ZeroDerived.base, i32 }
%struct.ZeroDerived.base = type { i8 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z4MakeRi(ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %retval = alloca %struct.ZeroDerived, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  %values = getelementptr inbounds nuw %struct.ZeroBase, ptr %retval, i32 0, i32 0
  %coerce.dive = getelementptr inbounds nuw %struct.ZeroDerived, ptr %retval, i32 0, i32 0
  %3 = load i64, ptr %coerce.dive, align 8
  ret i64 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z8Identity11ZeroDerived(i64 %value.coerce) #0 {
entry:
  %retval = alloca %struct.ZeroDerived, align 8
  %value = alloca %struct.ZeroDerived, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.ZeroDerived, ptr %value, i32 0, i32 0
  store i64 %value.coerce, ptr %coerce.dive, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %value, i64 8, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %struct.ZeroDerived, ptr %retval, i32 0, i32 0
  %0 = load i64, ptr %coerce.dive1, align 8
  ret i64 %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i64 @_Z4FormRi(ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %retval = alloca %struct.Occupied, align 8
  %counter.addr = alloca ptr, align 8
  %ref.tmp = alloca %struct.ZeroDerived, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call i64 @_Z4MakeRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %coerce.dive = getelementptr inbounds nuw %struct.ZeroDerived, ptr %ref.tmp, i32 0, i32 0
  %coerce.val.ii = trunc i64 %call to i8
  store i8 %coerce.val.ii, ptr %coerce.dive, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %retval, ptr align 8 %ref.tmp, i64 8, i1 false)
  %1 = getelementptr inbounds i8, ptr %retval, i64 1
  %number = getelementptr inbounds nuw %struct.Occupied, ptr %retval, i32 0, i32 1
  store i32 1, ptr %number, align 4
  %2 = load i64, ptr %retval, align 8
  ret i64 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z4SameR8Occupied(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = getelementptr inbounds i8, ptr %0, i64 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %cmp = icmp eq ptr %1, %2
  ret i1 %cmp
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z4BaseR8Occupied(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  ret ptr %0
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
