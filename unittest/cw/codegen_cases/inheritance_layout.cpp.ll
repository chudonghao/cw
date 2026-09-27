; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names inheritance_layout.cpp -o -
; ModuleID = 'inheritance_layout.cpp'
source_filename = "inheritance_layout.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Leaf = type { %struct.Middle.base, i8, [2 x i8] }
%struct.Middle.base = type <{ %struct.Root, i8 }>
%struct.Root = type { i32 }
%struct.Middle = type <{ %struct.Root, i8, [3 x i8] }>
%struct.Box = type { i8, [3 x i8], %struct.Leaf }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z6Fieldsihh(i32 noundef %number, i8 noundef zeroext %tag, i8 noundef zeroext %extra) #0 {
entry:
  %number.addr = alloca i32, align 4
  %tag.addr = alloca i8, align 1
  %extra.addr = alloca i8, align 1
  %value = alloca %struct.Leaf, align 4
  store i32 %number, ptr %number.addr, align 4
  store i8 %tag, ptr %tag.addr, align 1
  store i8 %extra, ptr %extra.addr, align 1
  %number1 = getelementptr inbounds nuw %struct.Root, ptr %value, i32 0, i32 0
  %0 = load i32, ptr %number.addr, align 4
  store i32 %0, ptr %number1, align 4
  %tag2 = getelementptr inbounds nuw %struct.Middle, ptr %value, i32 0, i32 1
  %1 = load i8, ptr %tag.addr, align 1
  store i8 %1, ptr %tag2, align 4
  %extra3 = getelementptr inbounds nuw %struct.Leaf, ptr %value, i32 0, i32 1
  %2 = load i8, ptr %extra.addr, align 1
  store i8 %2, ptr %extra3, align 1
  %number4 = getelementptr inbounds nuw %struct.Root, ptr %value, i32 0, i32 0
  %3 = load i32, ptr %number4, align 4
  ret i32 %3
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z5ExtraR4Leaf(ptr noundef nonnull align 4 dereferenceable(6) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %extra = getelementptr inbounds nuw %struct.Leaf, ptr %0, i32 0, i32 1
  ret ptr %extra
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7ElementRA2_K4Leafm(ptr noundef nonnull align 4 dereferenceable(16) %values, i64 noundef %index) #0 {
entry:
  %values.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %values, ptr %values.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %values.addr, align 8, !nonnull !5, !align !6
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [2 x %struct.Leaf], ptr %0, i64 0, i64 %1
  %number = getelementptr inbounds nuw %struct.Root, ptr %arrayidx, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z6NestedR3Box(ptr noundef nonnull align 4 dereferenceable(12) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %struct.Box, ptr %0, i32 0, i32 2
  %extra = getelementptr inbounds nuw %struct.Leaf, ptr %value1, i32 0, i32 1
  ret ptr %extra
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
