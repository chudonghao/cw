; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names array_initialization.cpp -o -
; ModuleID = 'array_initialization.cpp'
source_filename = "array_initialization.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8Integersim(i32 noundef %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca i32, align 4
  %index.addr = alloca i64, align 8
  %values = alloca [2 x i32], align 4
  store i32 %value, ptr %value.addr, align 4
  store i64 %index, ptr %index.addr, align 8
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %values, align 4
  %arrayinit.element = getelementptr inbounds i32, ptr %values, i64 1
  store i32 7, ptr %arrayinit.element, align 4
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 %1
  %2 = load i32, ptr %arrayidx, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i16 @_Z6Nestedsmm(i16 noundef signext %value, i64 noundef %outer, i64 noundef %inner) #0 {
entry:
  %value.addr = alloca i16, align 2
  %outer.addr = alloca i64, align 8
  %inner.addr = alloca i64, align 8
  %values = alloca [2 x [1 x i16]], align 2
  store i16 %value, ptr %value.addr, align 2
  store i64 %outer, ptr %outer.addr, align 8
  store i64 %inner, ptr %inner.addr, align 8
  %0 = load i16, ptr %value.addr, align 2
  %arrayidx = getelementptr inbounds [2 x [1 x i16]], ptr %values, i64 0, i64 0
  %arrayidx1 = getelementptr inbounds [1 x i16], ptr %arrayidx, i64 0, i64 0
  store i16 %0, ptr %arrayidx1, align 2
  %arrayidx2 = getelementptr inbounds [2 x [1 x i16]], ptr %values, i64 0, i64 1
  %arrayidx3 = getelementptr inbounds [1 x i16], ptr %arrayidx2, i64 0, i64 0
  store i16 5, ptr %arrayidx3, align 2
  %1 = load i64, ptr %outer.addr, align 8
  %arrayidx4 = getelementptr inbounds nuw [2 x [1 x i16]], ptr %values, i64 0, i64 %1
  %2 = load i64, ptr %inner.addr, align 8
  %arrayidx5 = getelementptr inbounds nuw [1 x i16], ptr %arrayidx4, i64 0, i64 %2
  %3 = load i16, ptr %arrayidx5, align 2
  ret i16 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z8Booleansbm(i1 noundef zeroext %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca i8, align 1
  %index.addr = alloca i64, align 8
  %values = alloca [2 x i8], align 1
  %storedv = zext i1 %value to i8
  store i8 %storedv, ptr %value.addr, align 1
  store i64 %index, ptr %index.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %storedv1 = zext i1 %loadedv to i8
  store i8 %storedv1, ptr %values, align 1
  %arrayinit.element = getelementptr inbounds i8, ptr %values, i64 1
  store i8 0, ptr %arrayinit.element, align 1
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x i8], ptr %values, i64 0, i64 %1
  %2 = load i8, ptr %arrayidx, align 1
  %loadedv2 = icmp ne i8 %2, 0
  ret i1 %loadedv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z8Floatingdm(double noundef %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca double, align 8
  %index.addr = alloca i64, align 8
  %values = alloca [2 x double], align 8
  store double %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  store double %0, ptr %values, align 8
  %arrayinit.element = getelementptr inbounds double, ptr %values, i64 1
  store double 2.500000e+00, ptr %arrayinit.element, align 8
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x double], ptr %values, i64 0, i64 %1
  %2 = load double, ptr %arrayidx, align 8
  ret double %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z8PointersPim(ptr noundef %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %values = alloca [2 x ptr], align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %values, align 8
  %arrayinit.element = getelementptr inbounds ptr, ptr %values, i64 1
  store ptr null, ptr %arrayinit.element, align 8
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x ptr], ptr %values, i64 0, i64 %1
  %2 = load ptr, ptr %arrayidx, align 8
  ret ptr %2
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
