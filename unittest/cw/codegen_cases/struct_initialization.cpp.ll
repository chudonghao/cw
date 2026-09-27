; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names struct_initialization.cpp -o -
; ModuleID = 'struct_initialization.cpp'
source_filename = "struct_initialization.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Padded = type { i8, i32, i8 }
%struct.Defaults = type { i16, i8, float, double, ptr, ptr, [2 x i32] }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z6Fieldsib(i32 noundef %number, i1 noundef zeroext %enabled) #0 {
entry:
  %number.addr = alloca i32, align 4
  %enabled.addr = alloca i8, align 1
  %value = alloca %struct.Padded, align 4
  store i32 %number, ptr %number.addr, align 4
  %storedv = zext i1 %enabled to i8
  store i8 %storedv, ptr %enabled.addr, align 1
  %tag = getelementptr inbounds nuw %struct.Padded, ptr %value, i32 0, i32 0
  store i8 1, ptr %tag, align 4
  %number1 = getelementptr inbounds nuw %struct.Padded, ptr %value, i32 0, i32 1
  %0 = load i32, ptr %number.addr, align 4
  store i32 %0, ptr %number1, align 4
  %enabled2 = getelementptr inbounds nuw %struct.Padded, ptr %value, i32 0, i32 2
  %1 = load i8, ptr %enabled.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  %storedv3 = zext i1 %loadedv to i8
  store i8 %storedv3, ptr %enabled2, align 4
  %enabled4 = getelementptr inbounds nuw %struct.Padded, ptr %value, i32 0, i32 2
  %2 = load i8, ptr %enabled4, align 4
  %loadedv5 = icmp ne i8 %2, 0
  ret i1 %loadedv5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7Defaultv() #0 {
entry:
  %value = alloca %struct.Defaults, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value, i8 0, i64 40, i1 false)
  %pointer = getelementptr inbounds nuw %struct.Defaults, ptr %value, i32 0, i32 4
  %0 = load ptr, ptr %pointer, align 8
  ret ptr %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
