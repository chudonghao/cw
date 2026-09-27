; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names array_evaluation.cpp -o -
; ModuleID = 'array_evaluation.cpp'
source_filename = "array_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Array = type { [2 x i32] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_Z6ChangeR5ArrayS0_m(ptr noundef nonnull align 4 dereferenceable(8) %source, ptr noundef nonnull align 4 dereferenceable(8) %target, i64 noundef %index) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %values = getelementptr inbounds nuw %struct.Array, ptr %0, i32 0, i32 0
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 %1
  store i32 9, ptr %arrayidx, align 4
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  ret ptr %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z8ExistingR5ArrayS0_m(ptr noundef nonnull align 4 dereferenceable(8) %source, ptr noundef nonnull align 4 dereferenceable(8) %target, i64 noundef %index) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %3 = load i64, ptr %index.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @_Z6ChangeR5ArrayS0_m(ptr noundef nonnull align 4 dereferenceable(8) %1, ptr noundef nonnull align 4 dereferenceable(8) %2, i64 noundef %3)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call, ptr align 4 %0, i64 8, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6FormedR5ArrayS0_m(ptr noundef nonnull align 4 dereferenceable(8) %source, ptr noundef nonnull align 4 dereferenceable(8) %target, i64 noundef %index) #0 {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %ref.tmp = alloca %struct.Array, align 4
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %values = getelementptr inbounds nuw %struct.Array, ptr %ref.tmp, i32 0, i32 0
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %values1 = getelementptr inbounds nuw %struct.Array, ptr %0, i32 0, i32 0
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %values1, i64 0, i64 %1
  %2 = load i32, ptr %arrayidx, align 4
  store i32 %2, ptr %values, align 4
  %arrayinit.element = getelementptr inbounds i32, ptr %values, i64 1
  %3 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %values2 = getelementptr inbounds nuw %struct.Array, ptr %3, i32 0, i32 0
  %4 = load i64, ptr %index.addr, align 8
  %arrayidx3 = getelementptr inbounds nuw [2 x i32], ptr %values2, i64 0, i64 %4
  %5 = load i32, ptr %arrayidx3, align 4
  store i32 %5, ptr %arrayinit.element, align 4
  %6 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %7 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %8 = load i64, ptr %index.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @_Z6ChangeR5ArrayS0_m(ptr noundef nonnull align 4 dereferenceable(8) %6, ptr noundef nonnull align 4 dereferenceable(8) %7, i64 noundef %8)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call, ptr align 4 %ref.tmp, i64 8, i1 false)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_Z6LocateR5ArrayRmm(ptr noundef nonnull align 4 dereferenceable(8) %value, ptr noundef nonnull align 8 dereferenceable(8) %index, i64 noundef %replacement) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %index.addr = alloca ptr, align 8
  %replacement.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %index, ptr %index.addr, align 8
  store i64 %replacement, ptr %replacement.addr, align 8
  %0 = load i64, ptr %replacement.addr, align 8
  %1 = load ptr, ptr %index.addr, align 8, !nonnull !5, !align !7
  store i64 %0, ptr %1, align 8
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4ReadR5ArrayRmm(ptr noundef nonnull align 4 dereferenceable(8) %value, ptr noundef nonnull align 8 dereferenceable(8) %index, i64 noundef %replacement) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %index.addr = alloca ptr, align 8
  %replacement.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %index, ptr %index.addr, align 8
  store i64 %replacement, ptr %replacement.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %index.addr, align 8, !nonnull !5, !align !7
  %2 = load i64, ptr %replacement.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @_Z6LocateR5ArrayRmm(ptr noundef nonnull align 4 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1, i64 noundef %2)
  %values = getelementptr inbounds nuw %struct.Array, ptr %call, i32 0, i32 0
  %3 = load ptr, ptr %index.addr, align 8, !nonnull !5, !align !7
  %4 = load i64, ptr %3, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 %4
  %5 = load i32, ptr %arrayidx, align 4
  ret i32 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4NextRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %4 = load i32, ptr %3, align 4
  ret i32 %4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8ElementsRim(ptr noundef nonnull align 4 dereferenceable(4) %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %values = alloca %struct.Array, align 4
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %values1 = getelementptr inbounds nuw %struct.Array, ptr %values, i32 0, i32 0
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4NextRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %values1, align 4
  %arrayinit.element = getelementptr inbounds i32, ptr %values1, i64 1
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call2 = call noundef i32 @_Z4NextRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i32 %call2, ptr %arrayinit.element, align 4
  %values3 = getelementptr inbounds nuw %struct.Array, ptr %values, i32 0, i32 0
  %2 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %values3, i64 0, i64 %2
  %3 = load i32, ptr %arrayidx, align 4
  ret i32 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z9DiscardedbRi(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  %agg.tmp.ensured = alloca %struct.Array, align 4
  %agg.tmp.ensured2 = alloca %struct.Array, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %value, ptr %value.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %values = getelementptr inbounds nuw %struct.Array, ptr %agg.tmp.ensured, i32 0, i32 0
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z4NextRi(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i32 %call, ptr %values, align 4
  %arrayinit.element = getelementptr inbounds i32, ptr %values, i64 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_Z4NextRi(ptr noundef nonnull align 4 dereferenceable(4) %2)
  store i32 %call1, ptr %arrayinit.element, align 4
  br label %cond.end

cond.false:                                       ; preds = %entry
  %values3 = getelementptr inbounds nuw %struct.Array, ptr %agg.tmp.ensured2, i32 0, i32 0
  store i32 0, ptr %values3, align 4
  %arrayinit.element4 = getelementptr inbounds i32, ptr %values3, i64 1
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call5 = call noundef i32 @_Z4NextRi(ptr noundef nonnull align 4 dereferenceable(4) %3)
  store i32 %call5, ptr %arrayinit.element4, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
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
!7 = !{i64 8}
