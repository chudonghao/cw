; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names indirect_evaluation.cpp -o -
; ModuleID = 'indirect_evaluation.cpp'
source_filename = "indirect_evaluation.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5Firsti(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5Otheri(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %sub = sub nsw i32 0, %0
  ret i32 %sub
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7ReplaceRPFiiE(ptr noundef nonnull align 8 dereferenceable(8) %callback) #0 {
entry:
  %callback.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8, !nonnull !5, !align !6
  store ptr @_Z5Otheri, ptr %0, align 8
  ret i32 5
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z6InvokeRPFiiE(ptr noundef nonnull align 8 dereferenceable(8) %callback) #1 {
entry:
  %callback.addr = alloca ptr, align 8
  %target = alloca ptr, align 8
  %value = alloca i32, align 4
  store ptr %callback, ptr %callback.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %0, align 8
  store ptr %1, ptr %target, align 8
  %2 = load ptr, ptr %callback.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_Z7ReplaceRPFiiE(ptr noundef nonnull align 8 dereferenceable(8) %2)
  store i32 %call, ptr %value, align 4
  %3 = load ptr, ptr %target, align 8
  %4 = load i32, ptr %value, align 4
  %call1 = call noundef i32 %3(i32 noundef %4)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z3Runv() #1 {
entry:
  %callback = alloca ptr, align 8
  store ptr @_Z5Firsti, ptr %callback, align 8
  %call = call noundef i32 @_Z6InvokeRPFiiE(ptr noundef nonnull align 8 dereferenceable(8) %callback)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z6MutateRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  %add = add nsw i32 %1, 1
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %4 = load i32, ptr %3, align 4
  ret i32 %4
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z9ArgumentsPFiiiERi(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %value) #1 {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %target = alloca ptr, align 8
  %first = alloca i32, align 4
  %second = alloca i32, align 4
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  store ptr %0, ptr %target, align 8
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %2 = load i32, ptr %1, align 4
  store i32 %2, ptr %first, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %call = call noundef i32 @_Z6MutateRi(ptr noundef nonnull align 4 dereferenceable(4) %3)
  store i32 %call, ptr %second, align 4
  %4 = load ptr, ptr %target, align 8
  %5 = load i32, ptr %first, align 4
  %6 = load i32, ptr %second, align 4
  %call1 = call noundef i32 %4(i32 noundef %5, i32 noundef %6)
  ret i32 %call1
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

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
