; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names array_references.cpp -o -
; ModuleID = 'array_references.cpp'
source_filename = "array_references.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@__const._Z14ThroughPointerRA2_im.callbacks = private unnamed_addr constant [1 x ptr] [ptr @_Z5FirstRA2_Kim], align 8

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5FirstRA2_Kim(ptr noundef nonnull align 4 dereferenceable(8) %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %0, i64 0, i64 %1
  %2 = load i32, ptr %arrayidx, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_Z7ForwardRA2_i(ptr noundef nonnull align 4 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(8) ptr @_Z11ForwardMoveOA2_i(ptr noundef nonnull align 4 dereferenceable(8) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z14ThroughPointerRA2_im(ptr noundef nonnull align 4 dereferenceable(8) %value, i64 noundef %index) #1 {
entry:
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %pointer = alloca ptr, align 8
  %bound = alloca ptr, align 8
  %callbacks = alloca [1 x ptr], align 8
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store ptr %0, ptr %pointer, align 8
  %1 = load ptr, ptr %pointer, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @_Z7ForwardRA2_i(ptr noundef nonnull align 4 dereferenceable(8) %1)
  store ptr %call, ptr %bound, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %callbacks, ptr align 8 @__const._Z14ThroughPointerRA2_im.callbacks, i64 8, i1 false)
  %2 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [1 x ptr], ptr %callbacks, i64 0, i64 %2
  %3 = load ptr, ptr %arrayidx, align 8
  %4 = load ptr, ptr %bound, align 8, !nonnull !5, !align !6
  %5 = load i64, ptr %index.addr, align 8
  %call1 = call noundef i32 %3(ptr noundef nonnull align 4 dereferenceable(8) %4, i64 noundef %5)
  store i32 %call1, ptr %left, align 4
  %6 = load ptr, ptr %bound, align 8, !nonnull !5, !align !6
  %call2 = call noundef nonnull align 4 dereferenceable(8) ptr @_Z11ForwardMoveOA2_i(ptr noundef nonnull align 4 dereferenceable(8) %6)
  %7 = load i64, ptr %index.addr, align 8
  %call3 = call noundef i32 @_Z5FirstRA2_Kim(ptr noundef nonnull align 4 dereferenceable(8) %call2, i64 noundef %7)
  store i32 %call3, ptr %right, align 4
  %8 = load i32, ptr %left, align 4
  %9 = load i32, ptr %right, align 4
  %add = add nsw i32 %8, %9
  ret i32 %add
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
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
