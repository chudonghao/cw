; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names operator_evaluation.cpp -o -
; ModuleID = 'operator_evaluation.cpp'
source_filename = "operator_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Value = type { i64 }
%struct.Empty = type { i8 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Zpl5Valuex(i64 %left.coerce, i64 noundef %right) #0 {
entry:
  %left = alloca %struct.Value, align 8
  %right.addr = alloca i64, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %left, i32 0, i32 0
  store i64 %left.coerce, ptr %coerce.dive, align 8
  store i64 %right, ptr %right.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %left, i32 0, i32 0
  %0 = load i64, ptr %number, align 8
  %1 = load i64, ptr %right.addr, align 8
  %add = add nsw i64 %0, %1
  %number1 = getelementptr inbounds nuw %struct.Value, ptr %left, i32 0, i32 0
  store i64 %add, ptr %number1, align 8
  %number2 = getelementptr inbounds nuw %struct.Value, ptr %left, i32 0, i32 0
  %2 = load i64, ptr %number2, align 8
  ret i64 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z6ChangeR5Value(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  store i64 9, ptr %number, align 8
  ret i64 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z7CaptureR5Value(ptr noundef nonnull align 8 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %first = alloca %struct.Value, align 8
  %second = alloca i64, align 8
  %agg.tmp = alloca %struct.Value, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %first, ptr align 8 %0, i64 8, i1 false)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i64 @_Z6ChangeR5Value(ptr noundef nonnull align 8 dereferenceable(8) %1)
  store i64 %call, ptr %second, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp, ptr align 8 %first, i64 8, i1 false)
  %2 = load i64, ptr %second, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %agg.tmp, i32 0, i32 0
  %3 = load i64, ptr %coerce.dive, align 8
  %call1 = call noundef i64 @_Zpl5Valuex(i64 %3, i64 noundef %2)
  ret i64 %call1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 8 dereferenceable(8) ptr @_Z6LocateR5ValueRi(ptr noundef nonnull align 8 dereferenceable(8) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %3
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z6InvokeR5ValueRi(ptr noundef nonnull align 8 dereferenceable(8) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) #2 {
entry:
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %object = alloca ptr, align 8
  %argument = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @_Z6LocateR5ValueRi(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  store ptr %call, ptr %object, align 8
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i64 @_Z6ChangeR5Value(ptr noundef nonnull align 8 dereferenceable(8) %2)
  store i64 %call1, ptr %argument, align 8
  %3 = load ptr, ptr %object, align 8, !nonnull !5, !align !6
  %4 = load i64, ptr %argument, align 8
  %call2 = call noundef i64 @_ZNK5ValueclEx(ptr noundef nonnull align 8 dereferenceable(8) %3, i64 noundef %4)
  ret i64 %call2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i64 @_ZNK5ValueclEx(ptr noundef nonnull align 8 dereferenceable(8) %this, i64 noundef %value) #0 {
entry:
  %this.addr = alloca ptr, align 8
  %value.addr = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store i64 %value, ptr %value.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %this1, i32 0, i32 0
  %0 = load i64, ptr %number, align 8
  %1 = load i64, ptr %value.addr, align 8
  %add = add nsw i64 %0, %1
  ret i64 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Znt5Empty() #0 {
entry:
  %value = alloca %struct.Empty, align 1
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z9MakeEmptyRi(ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  store i32 %add, ptr %2, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z11EmptyResultRi(ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %counter.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.Empty, align 1
  %undef.agg.tmp = alloca %struct.Empty, align 1
  %undef.agg.tmp1 = alloca %struct.Empty, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !7
  call void @_Z9MakeEmptyRi(ptr noundef nonnull align 4 dereferenceable(4) %0)
  call void @_Znt5Empty()
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 8}
!7 = !{i64 4}
