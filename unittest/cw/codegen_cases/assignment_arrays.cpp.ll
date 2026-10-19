; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names assignment_arrays.cpp -o -
; ModuleID = 'assignment_arrays.cpp'
source_filename = "assignment_arrays.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Receipt = type { i8 }
%struct.Base = type { i32 }
%struct.Item = type { %struct.Base }

@trace = global i64 0, align 8

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z6AssignR4Base4Item(ptr dead_on_unwind noalias writable sret(%struct.Receipt) align 1 %agg.result, ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef align 4 %source) #0 {
entry:
  %result.ptr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.indirect_addr = alloca ptr, align 8
  store ptr %agg.result, ptr %result.ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.indirect_addr, align 8
  %value = getelementptr inbounds nuw %struct.Base, ptr %source, i32 0, i32 0
  %0 = load i32, ptr %value, align 4
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %1, i32 0, i32 0
  store i32 %0, ptr %value1, align 4
  %2 = load i64, ptr @trace, align 8
  %mul = mul nsw i64 %2, 10
  %add = add nsw i64 %mul, 5
  store i64 %add, ptr @trace, align 8
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4CopyRA2_4ItemRA2_KS_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %i = alloca i32, align 4
  %agg.tmp.ensured = alloca %struct.Receipt, align 1
  %agg.tmp = alloca %struct.Item, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %cmp = icmp slt i32 %0, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %i, align 4
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [2 x %struct.Item], ptr %1, i64 0, i64 %idxprom
  %3 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %4 = load i32, ptr %i, align 4
  %idxprom1 = sext i32 %4 to i64
  %arrayidx2 = getelementptr inbounds [2 x %struct.Item], ptr %3, i64 0, i64 %idxprom1
  %call = call noundef ptr @_ZN4ItemC1ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %agg.tmp, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx2)
  call void @_Z6AssignR4Base4Item(ptr dead_on_unwind writable sret(%struct.Receipt) align 1 %agg.tmp.ensured, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx, ptr noundef align 4 %agg.tmp)
  %call3 = call noundef ptr @_ZN7ReceiptD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp.ensured) #2
  %call4 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %agg.tmp) #2
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i32, ptr %i, align 4
  %inc = add nsw i32 %5, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !7

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC1ERKS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %call = call noundef ptr @_ZN4ItemC2ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN7ReceiptD1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN7ReceiptD2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z4MoveRA2_4ItemOS0_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %i = alloca i32, align 4
  %agg.tmp.ensured = alloca %struct.Receipt, align 1
  %agg.tmp = alloca %struct.Item, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %cmp = icmp slt i32 %0, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %i, align 4
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [2 x %struct.Item], ptr %1, i64 0, i64 %idxprom
  %3 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %4 = load i32, ptr %i, align 4
  %idxprom1 = sext i32 %4 to i64
  %arrayidx2 = getelementptr inbounds [2 x %struct.Item], ptr %3, i64 0, i64 %idxprom1
  %call = call noundef ptr @_ZN4ItemC1EOS_(ptr noundef nonnull align 4 dereferenceable(4) %agg.tmp, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx2)
  call void @_Z6AssignR4Base4Item(ptr dead_on_unwind writable sret(%struct.Receipt) align 1 %agg.tmp.ensured, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx, ptr noundef align 4 %agg.tmp)
  %call3 = call noundef ptr @_ZN7ReceiptD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp.ensured) #2
  %call4 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %agg.tmp) #2
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i32, ptr %i, align 4
  %inc = add nsw i32 %5, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !9

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC1EOS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %call = call noundef ptr @_ZN4ItemC2EOS_(ptr noundef nonnull align 4 dereferenceable(4) %this1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6NestedRA1_A2_4ItemRA1_A2_KS_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %agg.tmp.ensured = alloca %struct.Receipt, align 1
  %agg.tmp = alloca %struct.Item, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc12, %entry
  %0 = load i32, ptr %i, align 4
  %cmp = icmp slt i32 %0, 1
  br i1 %cmp, label %for.body, label %for.end14

for.body:                                         ; preds = %for.cond
  store i32 0, ptr %j, align 4
  br label %for.cond1

for.cond1:                                        ; preds = %for.inc, %for.body
  %1 = load i32, ptr %j, align 4
  %cmp2 = icmp slt i32 %1, 2
  br i1 %cmp2, label %for.body3, label %for.end

for.body3:                                        ; preds = %for.cond1
  %2 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %i, align 4
  %idxprom = sext i32 %3 to i64
  %arrayidx = getelementptr inbounds [1 x [2 x %struct.Item]], ptr %2, i64 0, i64 %idxprom
  %4 = load i32, ptr %j, align 4
  %idxprom4 = sext i32 %4 to i64
  %arrayidx5 = getelementptr inbounds [2 x %struct.Item], ptr %arrayidx, i64 0, i64 %idxprom4
  %5 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %6 = load i32, ptr %i, align 4
  %idxprom6 = sext i32 %6 to i64
  %arrayidx7 = getelementptr inbounds [1 x [2 x %struct.Item]], ptr %5, i64 0, i64 %idxprom6
  %7 = load i32, ptr %j, align 4
  %idxprom8 = sext i32 %7 to i64
  %arrayidx9 = getelementptr inbounds [2 x %struct.Item], ptr %arrayidx7, i64 0, i64 %idxprom8
  %call = call noundef ptr @_ZN4ItemC1ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %agg.tmp, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx9)
  call void @_Z6AssignR4Base4Item(ptr dead_on_unwind writable sret(%struct.Receipt) align 1 %agg.tmp.ensured, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx5, ptr noundef align 4 %agg.tmp)
  %call10 = call noundef ptr @_ZN7ReceiptD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %agg.tmp.ensured) #2
  %call11 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %agg.tmp) #2
  br label %for.inc

for.inc:                                          ; preds = %for.body3
  %8 = load i32, ptr %j, align 4
  %inc = add nsw i32 %8, 1
  store i32 %inc, ptr %j, align 4
  br label %for.cond1, !llvm.loop !10

for.end:                                          ; preds = %for.cond1
  br label %for.inc12

for.inc12:                                        ; preds = %for.end
  %9 = load i32, ptr %i, align 4
  %inc13 = add nsw i32 %9, 1
  store i32 %inc13, ptr %i, align 4
  br label %for.cond, !llvm.loop !11

for.end14:                                        ; preds = %for.cond
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z4ZeroRA0_4ItemRA0_KS_(ptr noundef nonnull align 4 %target, ptr noundef nonnull align 4 %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN7ByValue6AssignE4ItemRK4Base(ptr noundef align 4 %target, ptr noundef nonnull align 4 dereferenceable(4) %source) #0 {
entry:
  %target.indirect_addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.indirect_addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %struct.Base, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %target, i32 0, i32 0
  store i32 %1, ptr %value1, align 4
  ret i32 7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_ZN7ByValue4CopyERA2_4ItemRA2_KS0_(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %i = alloca i32, align 4
  %agg.tmp = alloca %struct.Item, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %cmp = icmp slt i32 %0, 2
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %i, align 4
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [2 x %struct.Item], ptr %1, i64 0, i64 %idxprom
  %call = call noundef ptr @_ZN4ItemC1ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %agg.tmp, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx)
  %3 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %4 = load i32, ptr %i, align 4
  %idxprom1 = sext i32 %4 to i64
  %arrayidx2 = getelementptr inbounds [2 x %struct.Item], ptr %3, i64 0, i64 %idxprom1
  %call3 = call noundef i32 @_ZN7ByValue6AssignE4ItemRK4Base(ptr noundef align 4 %agg.tmp, ptr noundef nonnull align 4 dereferenceable(4) %arrayidx2)
  %call4 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %agg.tmp) #2
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %5 = load i32, ptr %i, align 4
  %inc = add nsw i32 %5, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !12

for.end:                                          ; preds = %for.cond
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef ptr @_ZN4BaseC2ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load i64, ptr @trace, align 8
  %mul = mul nsw i64 %1, 10
  %add = add nsw i64 %mul, 2
  store i64 %add, ptr @trace, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4BaseC2ERKS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Base, ptr %this1, i32 0, i32 0
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %value2 = getelementptr inbounds nuw %struct.Base, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value2, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN7ReceiptD2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i64, ptr @trace, align 8
  %mul = mul nsw i64 %0, 10
  %add = add nsw i64 %mul, 6
  store i64 %add, ptr @trace, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i64, ptr @trace, align 8
  %mul = mul nsw i64 %0, 10
  %add = add nsw i64 %mul, 4
  store i64 %add, ptr @trace, align 8
  %call = call noundef ptr @_ZN4BaseD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4BaseD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC2EOS_(ptr noundef nonnull returned align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %call = call noundef ptr @_ZN4BaseC2ERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load i64, ptr @trace, align 8
  %mul = mul nsw i64 %1, 10
  %add = add nsw i64 %mul, 3
  store i64 %add, ptr @trace, align 8
  ret ptr %this1
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nounwind }

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
