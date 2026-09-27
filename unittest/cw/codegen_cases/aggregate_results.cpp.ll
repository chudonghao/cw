; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names aggregate_results.cpp -o -
; ModuleID = 'aggregate_results.cpp'
source_filename = "aggregate_results.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Value = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i32 @_Z4Makei(i32 noundef %value) #0 {
entry:
  %retval = alloca %struct.Value, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %number = getelementptr inbounds nuw %struct.Value, ptr %retval, i32 0, i32 0
  store i32 %0, ptr %number, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %retval, i32 0, i32 0
  %1 = load i32, ptr %coerce.dive, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i32 @_Z6Choosebii(i1 noundef zeroext %flag, i32 noundef %left, i32 noundef %right) #0 {
entry:
  %retval = alloca %struct.Value, align 4
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i32, ptr %left.addr, align 4
  %call = call i32 @_Z4Makei(i32 noundef %1)
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %retval, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load i32, ptr %right.addr, align 4
  %call1 = call i32 @_Z4Makei(i32 noundef %2)
  %coerce.dive2 = getelementptr inbounds nuw %struct.Value, ptr %retval, i32 0, i32 0
  store i32 %call1, ptr %coerce.dive2, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %coerce.dive3 = getelementptr inbounds nuw %struct.Value, ptr %retval, i32 0, i32 0
  %3 = load i32, ptr %coerce.dive3, align 4
  ret i32 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4ReadRK5Value(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4Bindi(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  %ref.tmp = alloca %struct.Value, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call i32 @_Z4Makei(i32 noundef %0)
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %ref.tmp, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %call1 = call noundef i32 @_Z4ReadRK5Value(ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z6Memberi(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  %ref.tmp = alloca %struct.Value, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call i32 @_Z4Makei(i32 noundef %0)
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %ref.tmp, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %number = getelementptr inbounds nuw %struct.Value, ptr %ref.tmp, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7Discardbi(i1 noundef zeroext %flag, i32 noundef %value) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %value.addr = alloca i32, align 4
  %coerce = alloca %struct.Value, align 4
  %coerce2 = alloca %struct.Value, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 %value, ptr %value.addr, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i32, ptr %value.addr, align 4
  %call = call i32 @_Z4Makei(i32 noundef %1)
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %coerce, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  br label %cond.end

cond.false:                                       ; preds = %entry
  %call1 = call i32 @_Z4Makei(i32 noundef 0)
  %coerce.dive3 = getelementptr inbounds nuw %struct.Value, ptr %coerce2, i32 0, i32 0
  store i32 %call1, ptr %coerce.dive3, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6TargetR5ValueRi(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  store i32 99, ptr %0, align 4
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6AssignR5ValueRi(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %result = alloca %struct.Value, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %call = call i32 @_Z4Makei(i32 noundef %1)
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %result, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6TargetR5ValueRi(ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call1, ptr align 4 %result, i64 4, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4Take5Value(i64 %value.coerce) #0 {
entry:
  %value = alloca %struct.Value, align 4
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %value, i32 0, i32 0
  %coerce.val.ii = trunc i64 %value.coerce to i32
  store i32 %coerce.val.ii, ptr %coerce.dive, align 4
  %number = getelementptr inbounds nuw %struct.Value, ptr %value, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8ReceiverRK5Value(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.Value, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.tmp, ptr align 4 %0, i64 4, i1 false)
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %agg.tmp, i32 0, i32 0
  %1 = load i32, ptr %coerce.dive, align 4
  %coerce.val.ii = zext i32 %1 to i64
  %call = call noundef i32 @_Z4Take5Value(i64 %coerce.val.ii)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4Passi(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  %agg.tmp = alloca %struct.Value, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call i32 @_Z4Makei(i32 noundef %0)
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %agg.tmp, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %coerce.dive1 = getelementptr inbounds nuw %struct.Value, ptr %agg.tmp, i32 0, i32 0
  %1 = load i32, ptr %coerce.dive1, align 4
  %coerce.val.ii = zext i32 %1 to i64
  %call2 = call noundef i32 @_Z4Take5Value(i64 %coerce.val.ii)
  ret i32 %call2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define i32 @_Z5Locali(i32 noundef %value) #0 {
entry:
  %retval = alloca %struct.Value, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call i32 @_Z4Makei(i32 noundef %0)
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %retval, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %coerce.dive1 = getelementptr inbounds nuw %struct.Value, ptr %retval, i32 0, i32 0
  %1 = load i32, ptr %coerce.dive1, align 4
  ret i32 %1
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
