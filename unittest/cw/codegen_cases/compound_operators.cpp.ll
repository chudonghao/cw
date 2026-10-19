; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names compound_operators.cpp -o -
; ModuleID = 'compound_operators.cpp'
source_filename = "compound_operators.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%"struct.Api::Value" = type { i32 }
%struct.Result = type { i32 }

@destroyed = global i32 0, align 4

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3ApipLENS_5ValueEi(i64 %left.coerce, i32 noundef %right) #0 {
entry:
  %left = alloca %"struct.Api::Value", align 4
  %right.addr = alloca i32, align 4
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %left, i32 0, i32 0
  %coerce.val.ii = trunc i64 %left.coerce to i32
  store i32 %coerce.val.ii, ptr %coerce.dive, align 4
  store i32 %right, ptr %right.addr, align 4
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %left, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  %1 = load i32, ptr %right.addr, align 4
  %add = add i32 %0, %1
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApimIERNS_5ValueES1_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_ZN3ApimLERNS_5ValueEi(ptr dead_on_unwind noalias writable sret(%struct.Result) align 4 %agg.result, ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) #1 {
entry:
  %result.ptr = alloca ptr, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %agg.result, ptr %result.ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %call = call noundef ptr @_ZN6ResultC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %agg.result, i32 noundef %0)
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6ResultC1Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %input) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr %input.addr, align 4
  %call = call noundef ptr @_ZN6ResultC2Ei(ptr noundef nonnull align 4 dereferenceable(4) %this1, i32 noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_ZN3ApidVERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %cmp = icmp eq i32 %0, -1
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %sub = sub i32 0, %2
  br label %cond.end

cond.false:                                       ; preds = %entry
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %number1 = getelementptr inbounds nuw %"struct.Api::Value", ptr %3, i32 0, i32 0
  %4 = load i32, ptr %number1, align 4
  %5 = load i32, ptr %right.addr, align 4
  %div = sdiv i32 %4, %5
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %sub, %cond.true ], [ %div, %cond.false ]
  %6 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %number2 = getelementptr inbounds nuw %"struct.Api::Value", ptr %6, i32 0, i32 0
  store i32 %cond, ptr %number2, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_ZN3ApirMERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %cmp = icmp eq i32 %0, -1
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %3 = load i32, ptr %right.addr, align 4
  %rem = srem i32 %2, %3
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ 0, %cond.true ], [ %rem, %cond.false ]
  %4 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %number1 = getelementptr inbounds nuw %"struct.Api::Value", ptr %4, i32 0, i32 0
  store i32 %cond, ptr %number1, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_ZN3ApiaNERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %and = and i32 %2, %0
  store i32 %and, ptr %number, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_ZN3ApioRERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %or = or i32 %2, %0
  store i32 %or, ptr %number, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_ZN3ApieOERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %xor = xor i32 %2, %0
  store i32 %xor, ptr %number, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_ZN3ApilSERNS_5ValueEx(ptr noundef nonnull align 4 dereferenceable(4) %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  ret i64 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApirSERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3Api6ChangeERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %0, i32 0, i32 0
  store i32 9, ptr %number, align 4
  ret i32 1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3Api6SyntaxERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %rhs = alloca i32, align 4
  %lhs = alloca %"struct.Api::Value", align 4
  %agg.tmp = alloca %"struct.Api::Value", align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZN3Api6ChangeERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %rhs, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %lhs, ptr align 4 %1, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.tmp, ptr align 4 %lhs, i64 4, i1 false)
  %2 = load i32, ptr %rhs, align 4
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %agg.tmp, i32 0, i32 0
  %3 = load i32, ptr %coerce.dive, align 4
  %coerce.val.ii = zext i32 %3 to i64
  %call1 = call noundef i32 @_ZN3ApipLENS_5ValueEi(i64 %coerce.val.ii, i32 noundef %2)
  ret i32 %call1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3Api8ExplicitERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %lhs = alloca %"struct.Api::Value", align 4
  %rhs = alloca i32, align 4
  %agg.tmp = alloca %"struct.Api::Value", align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %lhs, ptr align 4 %0, i64 4, i1 false)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZN3Api6ChangeERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i32 %call, ptr %rhs, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.tmp, ptr align 4 %lhs, i64 4, i1 false)
  %2 = load i32, ptr %rhs, align 4
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %agg.tmp, i32 0, i32 0
  %3 = load i32, ptr %coerce.dive, align 4
  %coerce.val.ii = zext i32 %3 to i64
  %call1 = call noundef i32 @_ZN3ApipLENS_5ValueEi(i64 %coerce.val.ii, i32 noundef %2)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_ZN3Api15ReferenceResultERNS_5ValueES1_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %target = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApimIERNS_5ValueES1_(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %call, i32 0, i32 0
  store ptr %number, ptr %target, align 8
  %2 = load ptr, ptr %target, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %2, align 4
  %add = add i32 %3, 3
  %4 = load ptr, ptr %target, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %4, align 4
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_ZN3Api5CallsERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #1 {
entry:
  %value.addr = alloca ptr, align 8
  %agg.tmp.ensured = alloca %struct.Result, align 4
  %target = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @_ZN3ApidVERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 1)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @_ZN3ApirMERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %1, i32 noundef 3)
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @_ZN3ApiaNERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %2, i32 noundef 7)
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @_ZN3ApioRERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %3, i32 noundef 1)
  %4 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @_ZN3ApieOERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %4, i32 noundef 2)
  %5 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @_ZN3ApimLERNS_5ValueEi(ptr dead_on_unwind writable sret(%struct.Result) align 4 %agg.tmp.ensured, ptr noundef nonnull align 4 dereferenceable(4) %5, i32 noundef 5)
  %call = call noundef ptr @_ZN6ResultD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %agg.tmp.ensured) #3
  %6 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApirSERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %6, i32 noundef -1)
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %call1, i32 0, i32 0
  store ptr %number, ptr %target, align 8
  %7 = load ptr, ptr %target, align 8, !nonnull !5, !align !6
  %8 = load i32, ptr %7, align 4
  %add = add i32 %8, 1
  %9 = load ptr, ptr %target, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %9, align 4
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6ResultD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN6ResultD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #3
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9QualifiedRN3Api5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %lhs = alloca %"struct.Api::Value", align 4
  %rhs = alloca i32, align 4
  %agg.tmp = alloca %"struct.Api::Value", align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %lhs, ptr align 4 %0, i64 4, i1 false)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZN3Api6ChangeERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i32 %call, ptr %rhs, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.tmp, ptr align 4 %lhs, i64 4, i1 false)
  %2 = load i32, ptr %rhs, align 4
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %agg.tmp, i32 0, i32 0
  %3 = load i32, ptr %coerce.dive, align 4
  %coerce.val.ii = zext i32 %3 to i64
  %call1 = call noundef i32 @_ZN3ApipLENS_5ValueEi(i64 %coerce.val.ii, i32 noundef %2)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8IndirectRN3Api5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #1 {
entry:
  %value.addr = alloca ptr, align 8
  %operation = alloca ptr, align 8
  %lhs = alloca %"struct.Api::Value", align 4
  %rhs = alloca i32, align 4
  %agg.tmp = alloca %"struct.Api::Value", align 4
  store ptr %value, ptr %value.addr, align 8
  store ptr @_ZN3ApipLENS_5ValueEi, ptr %operation, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %lhs, ptr align 4 %0, i64 4, i1 false)
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZN3Api6ChangeERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i32 %call, ptr %rhs, align 4
  %2 = load ptr, ptr %operation, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.tmp, ptr align 4 %lhs, i64 4, i1 false)
  %3 = load i32, ptr %rhs, align 4
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %agg.tmp, i32 0, i32 0
  %4 = load i32, ptr %coerce.dive, align 4
  %coerce.val.ii = zext i32 %4 to i64
  %call1 = call noundef i32 %2(i64 %coerce.val.ii, i32 noundef %3)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z13UnmaskedCountRN3Api5ValueEx(ptr noundef nonnull align 4 dereferenceable(4) %value, i64 noundef %count) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i64, ptr %count.addr, align 8
  %call = call noundef i64 @_ZN3ApilSERNS_5ValueEx(ptr noundef nonnull align 4 dereferenceable(4) %0, i64 noundef %1)
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6ResultC2Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %input) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Result, ptr %this1, i32 0, i32 0
  %0 = load i32, ptr %input.addr, align 4
  store i32 %0, ptr %value, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN6ResultD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr @destroyed, align 4
  %add = add i32 %0, 1
  store i32 %add, ptr @destroyed, align 4
  ret ptr %this1
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
