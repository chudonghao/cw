; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names callable_objects.cpp -o -
; ModuleID = 'callable_objects.cpp'
source_filename = "callable_objects.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Callable = type { i32 }

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z6InvokeR7Derivedi(ptr noundef nonnull align 4 dereferenceable(8) %object, i32 noundef %value) #0 {
entry:
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %object, ptr %object.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %object.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %value.addr, align 4
  %call = call noundef i32 @_ZN8CallableclEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %1)
  %2 = load ptr, ptr %object.addr, align 8, !nonnull !5, !align !6
  %3 = load i32, ptr %value.addr, align 4
  %call1 = call noundef i32 @_ZN8CallableclEi(ptr noundef nonnull align 4 dereferenceable(4) %2, i32 noundef %3)
  ret i32 %call1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_ZN8CallableclEi(ptr noundef nonnull align 4 dereferenceable(4) %this, i32 noundef %argument) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %argument.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %argument, ptr %argument.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr %argument.addr, align 4
  %value = getelementptr inbounds nuw %struct.Callable, ptr %this1, i32 0, i32 0
  store i32 %0, ptr %value, align 4
  %value2 = getelementptr inbounds nuw %struct.Callable, ptr %this1, i32 0, i32 0
  %1 = load i32, ptr %value2, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z4ReadRK7Derivedi(ptr noundef nonnull align 4 dereferenceable(8) %object, i32 noundef %value) #0 {
entry:
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %object, ptr %object.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %object.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %value.addr, align 4
  %call = call noundef i32 @_ZNK8CallableclEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %1)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_ZNK8CallableclEi(ptr noundef nonnull align 4 dereferenceable(4) %this, i32 noundef %argument) #1 {
entry:
  %this.addr = alloca ptr, align 8
  %argument.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %argument, ptr %argument.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Callable, ptr %this1, i32 0, i32 0
  %0 = load i32, ptr %value, align 4
  %1 = load i32, ptr %argument.addr, align 4
  %add = add nsw i32 %0, %1
  ret i32 %add
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z7PointerP8Callablei(ptr noundef %object, i32 noundef %value) #0 {
entry:
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %object, ptr %object.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %object.addr, align 8
  %1 = load i32, ptr %value.addr, align 4
  %call = call noundef i32 @_ZN8CallableclEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %1)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z9Temporaryi(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  %ref.tmp = alloca %struct.Callable, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Callable, ptr %ref.tmp, i32 0, i32 0
  store i32 0, ptr %value1, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call noundef i32 @_ZNK8CallableclEi(ptr noundef nonnull align 4 dereferenceable(4) %ref.tmp, i32 noundef %0)
  ret i32 %call
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
