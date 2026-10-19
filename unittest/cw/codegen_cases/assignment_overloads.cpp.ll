; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names assignment_overloads.cpp -o -
; ModuleID = 'assignment_overloads.cpp'
source_filename = "assignment_overloads.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Value = type { i32 }
%struct.Box = type { i32 }

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z7MutableR5Value(ptr noundef nonnull align 4 dereferenceable(4) %target) #0 {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZNR5ValueaSEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 7)
  ret ptr %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef nonnull align 4 dereferenceable(4) ptr @_ZNR5ValueaSEi(ptr noundef nonnull align 4 dereferenceable(4) %this, i32 noundef %source) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %source, ptr %source.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr %source.addr, align 4
  %number = getelementptr inbounds nuw %struct.Value, ptr %this1, i32 0, i32 0
  store i32 %0, ptr %number, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8ReadonlyRK5Value(ptr noundef nonnull align 4 dereferenceable(4) %target) #0 {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZNKR5ValueaSEb(ptr noundef nonnull align 4 dereferenceable(4) %0, i1 noundef zeroext true)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_ZNKR5ValueaSEb(ptr noundef nonnull align 4 dereferenceable(4) %this, i1 noundef zeroext %source) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca i8, align 1
  store ptr %this, ptr %this.addr, align 8
  %storedv = zext i1 %source to i8
  store i8 %storedv, ptr %source.addr, align 1
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i8, ptr %source.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %number = getelementptr inbounds nuw %struct.Value, ptr %this1, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %1, %cond.true ], [ 0, %cond.false ]
  ret i32 %cond
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z9Temporaryv() #0 {
entry:
  %ref.tmp = alloca %struct.Value, align 4
  %number = getelementptr inbounds nuw %struct.Value, ptr %ref.tmp, i32 0, i32 0
  store i32 0, ptr %number, align 4
  %call = call noundef i32 @_ZNKR5ValueaSEb(ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp, i1 noundef zeroext true)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11AssignValue5ValuePi(i64 %target.coerce, ptr noundef %source) #1 {
entry:
  %target = alloca %struct.Value, align 4
  %source.addr = alloca ptr, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %target, i32 0, i32 0
  %coerce.val.ii = trunc i64 %target.coerce to i32
  store i32 %coerce.val.ii, ptr %coerce.dive, align 4
  store ptr %source, ptr %source.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %target, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  %1 = load ptr, ptr %source.addr, align 8
  %2 = load i32, ptr %1, align 4
  %add = add nsw i32 %0, %2
  ret i32 %add
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7ByValueRK5ValuePi(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef %source) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %agg.tmp = alloca %struct.Value, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.tmp, ptr align 4 %0, i64 4, i1 false)
  %1 = load ptr, ptr %source.addr, align 8
  %coerce.dive = getelementptr inbounds nuw %struct.Value, ptr %agg.tmp, i32 0, i32 0
  %2 = load i32, ptr %coerce.dive, align 4
  %coerce.val.ii = zext i32 %2 to i64
  %call = call noundef i32 @_Z11AssignValue5ValuePi(i64 %coerce.val.ii, ptr noundef %1)
  ret i32 %call
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_Z5SliceR4BaseRK7Derived(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(9) %source) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 8, i1 false)
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(9) ptr @_Z4MoveR7DerivedOS_(ptr noundef nonnull align 4 dereferenceable(9) %target, ptr noundef nonnull align 4 dereferenceable(9) %source) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 9, i1 false)
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(9) ptr @_Z8MoveWinsR7DerivedOS_(ptr noundef nonnull align 4 dereferenceable(9) %target, ptr noundef nonnull align 4 dereferenceable(9) %source) #1 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 9, i1 false)
  ret ptr %1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z13MutableSourceR3BoxS0_(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZN3BoxaSERS_(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_ZN3BoxaSERS_(ptr noundef nonnull align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %struct.Box, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %value2 = getelementptr inbounds nuw %struct.Box, ptr %this1, i32 0, i32 0
  store i32 %1, ptr %value2, align 4
  ret i32 1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z11ConstSourceR3BoxRKS_(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) #0 {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %target.addr, align 8, !nonnull !5, !align !6
  %call = call noundef zeroext i1 @_ZN3BoxaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret i1 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef zeroext i1 @_ZN3BoxaSERKS_(ptr noundef nonnull align 4 dereferenceable(4) %this, ptr noundef nonnull align 4 dereferenceable(4) %source) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %struct.Box, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %value2 = getelementptr inbounds nuw %struct.Box, ptr %this1, i32 0, i32 0
  store i32 %1, ptr %value2, align 4
  ret i1 true
}

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
