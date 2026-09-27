; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names struct_aggregates.cpp -o -
; ModuleID = 'struct_aggregates.cpp'
source_filename = "struct_aggregates.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Outer = type { i8, %struct.Inner, [2 x %struct.Inner] }
%struct.Inner = type { i16 }
%struct.ArrayValue = type { [2 x %struct.Outer] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i16 @_Z6Nestedsm(i16 noundef signext %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca i16, align 2
  %index.addr = alloca i64, align 8
  %object = alloca %struct.Outer, align 2
  store i16 %value, ptr %value.addr, align 2
  store i64 %index, ptr %index.addr, align 8
  %leading = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 0
  store i8 1, ptr %leading, align 2
  %inner = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 1
  %value1 = getelementptr inbounds nuw %struct.Inner, ptr %inner, i32 0, i32 0
  %0 = load i16, ptr %value.addr, align 2
  store i16 %0, ptr %value1, align 2
  %items = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 2
  %value2 = getelementptr inbounds nuw %struct.Inner, ptr %items, i32 0, i32 0
  store i16 0, ptr %value2, align 2
  %arrayinit.element = getelementptr inbounds %struct.Inner, ptr %items, i64 1
  %inner3 = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 2 %arrayinit.element, ptr align 2 %inner3, i64 2, i1 false)
  %items4 = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 2
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Inner], ptr %items4, i64 0, i64 %1
  %value5 = getelementptr inbounds nuw %struct.Inner, ptr %arrayidx, i32 0, i32 0
  %2 = load i16, ptr %value5, align 2
  ret i16 %2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i16 @_Z5ArrayRK10ArrayValuem(ptr noundef nonnull align 2 dereferenceable(16) %source, i64 noundef %index) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %copied = alloca %struct.ArrayValue, align 2
  store ptr %source, ptr %source.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 2 %copied, ptr align 2 %0, i64 16, i1 false)
  %items = getelementptr inbounds nuw %struct.ArrayValue, ptr %copied, i32 0, i32 0
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Outer], ptr %items, i64 0, i64 %1
  %items1 = getelementptr inbounds nuw %struct.Outer, ptr %arrayidx, i32 0, i32 2
  %2 = load i64, ptr %index.addr, align 8
  %arrayidx2 = getelementptr inbounds nuw [2 x %struct.Inner], ptr %items1, i64 0, i64 %2
  %value = getelementptr inbounds nuw %struct.Inner, ptr %arrayidx2, i32 0, i32 0
  %3 = load i16, ptr %value, align 2
  ret i16 %3
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
!6 = !{i64 2}
