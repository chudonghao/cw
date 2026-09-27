; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names inheritance_evaluation.cpp -o -
; ModuleID = 'inheritance_evaluation.cpp'
source_filename = "inheritance_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Derived = type { %struct.Base, i32 }
%struct.Base = type { i32 }

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6AssignPFR7DerivedRiES3_S1_(ptr noundef %source, ptr noundef %target, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %value = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(8) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store ptr %call, ptr %value, align 8
  %2 = load ptr, ptr %value, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %target.addr, align 8
  %4 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef nonnull align 4 dereferenceable(8) ptr %3(ptr noundef nonnull align 4 dereferenceable(4) %4)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call1, ptr align 4 %2, i64 4, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_Z7ConvertPFP7DerivedRiES1_(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z9TemporaryPF7DerivedRiES0_(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %ref.tmp = alloca %struct.Derived, align 4
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call i64 %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i64 %call, ptr %ref.tmp, align 4
  %number = getelementptr inbounds nuw %struct.Base, ptr %ref.tmp, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  ret i32 %2
}

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
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
