; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names call_evaluation.cpp -o -
; ModuleID = 'call_evaluation.cpp'
source_filename = "call_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7ReplaceRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 67, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %1, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5Firstii(i32 noundef %first, i32 noundef %second) #0 {
entry:
  %first.addr = alloca i32, align 4
  %second.addr = alloca i32, align 4
  store i32 %first, ptr %first.addr, align 4
  store i32 %second, ptr %second.addr, align 4
  %0 = load i32, ptr %first.addr, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z12OrdinaryCallv() #0 {
entry:
  %value = alloca i32, align 4
  store i32 13, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %call = call noundef i32 @_Z7ReplaceRi(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call1 = call noundef i32 @_Z5Firstii(i32 noundef %0, i32 noundef %call)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z12ReceiverCallv() #0 {
entry:
  %value = alloca i32, align 4
  store i32 13, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %call = call noundef i32 @_Z7ReplaceRi(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call1 = call noundef i32 @_Z5Firstii(i32 noundef %0, i32 noundef %call)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z16ConditionalFirstii(i32 noundef %value, i32 noundef %ignored) #0 {
entry:
  %value.addr = alloca i32, align 4
  %ignored.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  store i32 %ignored, ptr %ignored.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z19ConditionalArgumentb(i1 noundef zeroext %flag) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %value = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 5, ptr %value, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i32, ptr %value, align 4
  br label %cond.end

cond.false:                                       ; preds = %entry
  store i32 7, ptr %value, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %1, %cond.true ], [ 7, %cond.false ]
  store i32 11, ptr %value, align 4
  %call = call noundef i32 @_Z16ConditionalFirstii(i32 noundef %cond, i32 noundef 11)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 23, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z14ReceiverSourcev() #0 {
entry:
  %value = alloca i32, align 4
  store i32 13, ptr %value, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRi(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %0 = load i32, ptr %call, align 4
  %call1 = call noundef i32 @_Z7ReplaceRi(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call2 = call noundef i32 @_Z5Firstii(i32 noundef %0, i32 noundef %call1)
  ret i32 %call2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9ReadFirstRKii(ptr noundef nonnull align 4 dereferenceable(4) %first, i32 noundef %ignored) #0 {
entry:
  %first.addr = alloca ptr, align 8
  %ignored.addr = alloca i32, align 4
  store ptr %first, ptr %first.addr, align 8
  store i32 %ignored, ptr %ignored.addr, align 4
  %0 = load ptr, ptr %first.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z17ReferenceArgumentv() #0 {
entry:
  %value = alloca i32, align 4
  store i32 13, ptr %value, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_Z6LocateRi(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call1 = call noundef i32 @_Z7ReplaceRi(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call2 = call noundef i32 @_Z9ReadFirstRKii(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef %call1)
  ret i32 %call2
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
