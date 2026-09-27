; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names object_array_assignment.cpp -o -
; ModuleID = 'object_array_assignment.cpp'
source_filename = "object_array_assignment.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Pair = type { [2 x %struct.Item] }
%struct.Item = type { i32 }
%struct.Matrix = type { [2 x [2 x %struct.Item]] }
%struct.CopyPair = type { [2 x %struct.CopyOnly] }
%struct.CopyOnly = type { i32 }
%struct.ZeroMatrix = type { [3 x [0 x %struct.Item]] }
%struct.EmptyPair = type { [2 x %struct.Empty] }
%struct.Empty = type { i8 }

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_Z4CopyR4PairRKS_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @_ZN4PairaSERKS_(ptr noundef nonnull align 4 dereferenceable(8) %1, ptr noundef nonnull align 4 dereferenceable(8) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 4 dereferenceable(8) ptr @_ZN4PairaSERKS_(ptr noundef nonnull align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %__i0 = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store i64 0, ptr %__i0, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i64, ptr %__i0, align 8
  %cmp = icmp ne i64 %1, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %elements = getelementptr inbounds nuw %struct.Pair, ptr %this1, i32 0, i32 0
  %2 = load i64, ptr %__i0, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Item], ptr %elements, i64 0, i64 %2
  %3 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements2 = getelementptr inbounds nuw %struct.Pair, ptr %3, i32 0, i32 0
  %4 = load i64, ptr %__i0, align 8
  %arrayidx3 = getelementptr inbounds nuw [2 x %struct.Item], ptr %elements2, i64 0, i64 %4
  call void @_ZN4ItemaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %arrayidx, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx3)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i64, ptr %__i0, align 8
  %inc = add i64 %5, 1
  store i64 %inc, ptr %__i0, align 8
  br label %for.cond, !llvm.loop !7

for.end:                                          ; preds = %for.cond
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_Z4MoveR4PairOS_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @_ZN4PairaSEOS_(ptr noundef nonnull align 4 dereferenceable(8) %1, ptr noundef nonnull align 4 dereferenceable(8) %0)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 4 dereferenceable(8) ptr @_ZN4PairaSEOS_(ptr noundef nonnull align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %__i0 = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store i64 0, ptr %__i0, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i64, ptr %__i0, align 8
  %cmp = icmp ne i64 %1, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %elements = getelementptr inbounds nuw %struct.Pair, ptr %this1, i32 0, i32 0
  %2 = load i64, ptr %__i0, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Item], ptr %elements, i64 0, i64 %2
  %3 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements2 = getelementptr inbounds nuw %struct.Pair, ptr %3, i32 0, i32 0
  %4 = load i64, ptr %__i0, align 8
  %arrayidx3 = getelementptr inbounds nuw [2 x %struct.Item], ptr %elements2, i64 0, i64 %4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN4ItemaSEOS_(ptr noundef nonnull align 4 dereferenceable(4) %arrayidx, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx3)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i64, ptr %__i0, align 8
  %inc = add i64 %5, 1
  store i64 %inc, ptr %__i0, align 8
  br label %for.cond, !llvm.loop !9

for.end:                                          ; preds = %for.cond
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6NestedR6MatrixRKS_(ptr noundef nonnull align 4 dereferenceable(16) %target, ptr noundef nonnull align 4 dereferenceable(16) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(16) ptr @_ZN6MatrixaSERKS_(ptr noundef nonnull align 4 dereferenceable(16) %1, ptr noundef nonnull align 4 dereferenceable(16) %0)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 4 dereferenceable(16) ptr @_ZN6MatrixaSERKS_(ptr noundef nonnull align 4 dereferenceable(16) %this, ptr noundef nonnull align 4 dereferenceable(16) %0) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %__i0 = alloca i64, align 8
  %__i1 = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store i64 0, ptr %__i0, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc9, %entry
  %1 = load i64, ptr %__i0, align 8
  %cmp = icmp ne i64 %1, 2
  br i1 %cmp, label %for.body, label %for.end11

for.body:                                         ; preds = %for.cond
  store i64 0, ptr %__i1, align 8
  br label %for.cond2

for.cond2:                                        ; preds = %for.inc, %for.body
  %2 = load i64, ptr %__i1, align 8
  %cmp3 = icmp ne i64 %2, 2
  br i1 %cmp3, label %for.body4, label %for.end

for.body4:                                        ; preds = %for.cond2
  %elements = getelementptr inbounds nuw %struct.Matrix, ptr %this1, i32 0, i32 0
  %3 = load i64, ptr %__i0, align 8
  %arrayidx = getelementptr inbounds nuw [2 x [2 x %struct.Item]], ptr %elements, i64 0, i64 %3
  %4 = load i64, ptr %__i1, align 8
  %arrayidx5 = getelementptr inbounds nuw [2 x %struct.Item], ptr %arrayidx, i64 0, i64 %4
  %5 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements6 = getelementptr inbounds nuw %struct.Matrix, ptr %5, i32 0, i32 0
  %6 = load i64, ptr %__i0, align 8
  %arrayidx7 = getelementptr inbounds nuw [2 x [2 x %struct.Item]], ptr %elements6, i64 0, i64 %6
  %7 = load i64, ptr %__i1, align 8
  %arrayidx8 = getelementptr inbounds nuw [2 x %struct.Item], ptr %arrayidx7, i64 0, i64 %7
  call void @_ZN4ItemaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %arrayidx5, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx8)
  br label %for.inc

for.inc:                                          ; preds = %for.body4
  %8 = load i64, ptr %__i1, align 8
  %inc = add i64 %8, 1
  store i64 %inc, ptr %__i1, align 8
  br label %for.cond2, !llvm.loop !10

for.end:                                          ; preds = %for.cond2
  br label %for.inc9

for.inc9:                                         ; preds = %for.end
  %9 = load i64, ptr %__i0, align 8
  %inc10 = add i64 %9, 1
  store i64 %inc10, ptr %__i0, align 8
  br label %for.cond, !llvm.loop !11

for.end11:                                        ; preds = %for.cond
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z8FallbackR8CopyPairOS_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @_ZN8CopyPairaSEOS_(ptr noundef nonnull align 4 dereferenceable(8) %1, ptr noundef nonnull align 4 dereferenceable(8) %0)
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 4 dereferenceable(8) ptr @_ZN8CopyPairaSEOS_(ptr noundef nonnull align 4 dereferenceable(8) %this, ptr noundef nonnull align 4 dereferenceable(8) %0) #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %__i0 = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store i64 0, ptr %__i0, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i64, ptr %__i0, align 8
  %cmp = icmp ne i64 %1, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %elements = getelementptr inbounds nuw %struct.CopyPair, ptr %this1, i32 0, i32 0
  %2 = load i64, ptr %__i0, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.CopyOnly], ptr %elements, i64 0, i64 %2
  %3 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements2 = getelementptr inbounds nuw %struct.CopyPair, ptr %3, i32 0, i32 0
  %4 = load i64, ptr %__i0, align 8
  %arrayidx3 = getelementptr inbounds nuw [2 x %struct.CopyOnly], ptr %elements2, i64 0, i64 %4
  %call = call noundef i32 @_ZN8CopyOnlyaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %arrayidx, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx3)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i64, ptr %__i0, align 8
  %inc = add i64 %5, 1
  store i64 %inc, ptr %__i0, align 8
  br label %for.cond, !llvm.loop !12

for.end:                                          ; preds = %for.cond
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(1) ptr @_Z10ZeroSourceRK10ZeroMatrixRi(ptr noundef nonnull align 4 dereferenceable(1) %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) #1 {
entry:
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %mul = mul nsw i32 %1, 10
  %add = add nsw i32 %mul, 1
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  ret ptr %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(1) ptr @_Z10ZeroTargetR10ZeroMatrixRi(ptr noundef nonnull align 4 dereferenceable(1) %target, ptr noundef nonnull align 4 dereferenceable(4) %counter) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %mul = mul nsw i32 %1, 10
  %add = add nsw i32 %mul, 2
  %2 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  ret ptr %3
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z10NestedZeroR10ZeroMatrixRKS_Ri(ptr noundef nonnull align 4 dereferenceable(1) %target, ptr noundef nonnull align 4 dereferenceable(1) %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(1) ptr @_Z10ZeroSourceRK10ZeroMatrixRi(ptr noundef nonnull align 4 dereferenceable(1) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %3 = load ptr, ptr %counter.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef nonnull align 4 dereferenceable(1) ptr @_Z10ZeroTargetR10ZeroMatrixRi(ptr noundef nonnull align 4 dereferenceable(1) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  %call2 = call noundef nonnull align 4 dereferenceable(1) ptr @_ZN10ZeroMatrixaSERKS_(ptr noundef nonnull align 4 dereferenceable(1) %call1, ptr noundef nonnull align 4 dereferenceable(1) %call)
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 4 dereferenceable(1) ptr @_ZN10ZeroMatrixaSERKS_(ptr noundef nonnull align 4 dereferenceable(1) %this, ptr noundef nonnull align 4 dereferenceable(1) %0) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %__i0 = alloca i64, align 8
  %__i1 = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store i64 0, ptr %__i0, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc9, %entry
  %1 = load i64, ptr %__i0, align 8
  %cmp = icmp ne i64 %1, 3
  br i1 %cmp, label %for.body, label %for.end11

for.body:                                         ; preds = %for.cond
  store i64 0, ptr %__i1, align 8
  br label %for.cond2

for.cond2:                                        ; preds = %for.inc, %for.body
  %2 = load i64, ptr %__i1, align 8
  %cmp3 = icmp ne i64 %2, 0
  br i1 %cmp3, label %for.body4, label %for.end

for.body4:                                        ; preds = %for.cond2
  %elements = getelementptr inbounds nuw %struct.ZeroMatrix, ptr %this1, i32 0, i32 0
  %3 = load i64, ptr %__i0, align 8
  %arrayidx = getelementptr inbounds nuw [3 x [0 x %struct.Item]], ptr %elements, i64 0, i64 %3
  %4 = load i64, ptr %__i1, align 8
  %arrayidx5 = getelementptr inbounds nuw [0 x %struct.Item], ptr %arrayidx, i64 0, i64 %4
  %5 = load ptr, ptr %.addr, align 8, !nonnull !5, !align !6
  %elements6 = getelementptr inbounds nuw %struct.ZeroMatrix, ptr %5, i32 0, i32 0
  %6 = load i64, ptr %__i0, align 8
  %arrayidx7 = getelementptr inbounds nuw [3 x [0 x %struct.Item]], ptr %elements6, i64 0, i64 %6
  %7 = load i64, ptr %__i1, align 8
  %arrayidx8 = getelementptr inbounds nuw [0 x %struct.Item], ptr %arrayidx7, i64 0, i64 %7
  call void @_ZN4ItemaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %arrayidx5, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx8)
  br label %for.inc

for.inc:                                          ; preds = %for.body4
  %8 = load i64, ptr %__i1, align 8
  %inc = add i64 %8, 1
  store i64 %inc, ptr %__i1, align 8
  br label %for.cond2, !llvm.loop !13

for.end:                                          ; preds = %for.cond2
  br label %for.inc9

for.inc9:                                         ; preds = %for.end
  %9 = load i64, ptr %__i0, align 8
  %inc10 = add i64 %9, 1
  store i64 %inc10, ptr %__i0, align 8
  br label %for.cond, !llvm.loop !14

for.end11:                                        ; preds = %for.cond
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z13EmptyElementsR9EmptyPairRKS_(ptr noundef nonnull align 1 dereferenceable(2) %target, ptr noundef nonnull align 1 dereferenceable(2) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5
  %call = call noundef nonnull align 1 dereferenceable(2) ptr @_ZN9EmptyPairaSERKS_(ptr noundef nonnull align 1 dereferenceable(2) %1, ptr noundef nonnull align 1 dereferenceable(2) %0)
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 1 dereferenceable(2) ptr @_ZN9EmptyPairaSERKS_(ptr noundef nonnull align 1 dereferenceable(2) %this, ptr noundef nonnull align 1 dereferenceable(2) %0) #0 {
entry:
  %this.addr = alloca ptr, align 8
  %.addr = alloca ptr, align 8
  %__i0 = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %0, ptr %.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  store i64 0, ptr %__i0, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i64, ptr %__i0, align 8
  %cmp = icmp ne i64 %1, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %elements = getelementptr inbounds nuw %struct.EmptyPair, ptr %this1, i32 0, i32 0
  %2 = load i64, ptr %__i0, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Empty], ptr %elements, i64 0, i64 %2
  %3 = load ptr, ptr %.addr, align 8, !nonnull !5
  %elements2 = getelementptr inbounds nuw %struct.EmptyPair, ptr %3, i32 0, i32 0
  %4 = load i64, ptr %__i0, align 8
  %arrayidx3 = getelementptr inbounds nuw [2 x %struct.Empty], ptr %elements2, i64 0, i64 %4
  call void @_ZN5EmptyaSERKS_(ptr noundef nonnull align 1 dereferenceable(1) %arrayidx, ptr noundef nonnull align 1 dereferenceable(1) %arrayidx3)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i64, ptr %__i0, align 8
  %inc = add i64 %5, 1
  store i64 %inc, ptr %__i0, align 8
  br label %for.cond, !llvm.loop !15

for.end:                                          ; preds = %for.cond
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr void @_ZN4ItemaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %value2 = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  store i32 %1, ptr %value2, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 4 dereferenceable(4) ptr @_ZN4ItemaSEOS_(ptr noundef nonnull align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %value2 = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  store i32 %1, ptr %value2, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_ZN8CopyOnlyaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %struct.CopyOnly, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %value2 = getelementptr inbounds nuw %struct.CopyOnly, ptr %this1, i32 0, i32 0
  store i32 %1, ptr %value2, align 4
  ret i32 7
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr void @_ZN5EmptyaSERKS_(ptr noundef nonnull align 1 dereferenceable(1) %this, ptr noundef nonnull align 1 dereferenceable(1) %source) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret void
}

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
!7 = distinct !{!7, !8}
!8 = !{!"llvm.loop.mustprogress"}
!9 = distinct !{!9, !8}
!10 = distinct !{!10, !8}
!11 = distinct !{!11, !8}
!12 = distinct !{!12, !8}
!13 = distinct !{!13, !8}
!14 = distinct !{!14, !8}
!15 = distinct !{!15, !8}
