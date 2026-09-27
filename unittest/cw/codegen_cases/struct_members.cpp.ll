; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names struct_members.cpp -o -
; ModuleID = 'struct_members.cpp'
source_filename = "struct_members.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Pair = type { i32, i32 }
%struct.Callback = type { ptr }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_Z6MemberR4Pairi(ptr noundef nonnull align 4 dereferenceable(8) %value, i32 noundef %input) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %0 = load i32, ptr %input.addr, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %second = getelementptr inbounds nuw %struct.Pair, ptr %1, i32 0, i32 1
  store i32 %0, ptr %second, align 4
  %2 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %second1 = getelementptr inbounds nuw %struct.Pair, ptr %2, i32 0, i32 1
  ret ptr %second1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7PointerP4Pairi(ptr noundef %value, i32 noundef %input) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %0 = load i32, ptr %input.addr, align 4
  %1 = load ptr, ptr %value.addr, align 8
  %first = getelementptr inbounds nuw %struct.Pair, ptr %1, i32 0, i32 0
  store i32 %0, ptr %first, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %first1 = getelementptr inbounds nuw %struct.Pair, ptr %2, i32 0, i32 0
  ret ptr %first1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z4CallRK8Callbacki(ptr noundef nonnull align 8 dereferenceable(8) %value, i32 noundef %input) #1 {
entry:
  %value.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !7
  %invoke = getelementptr inbounds nuw %struct.Callback, ptr %0, i32 0, i32 0
  %1 = load ptr, ptr %invoke, align 8
  %2 = load i32, ptr %input.addr, align 4
  %call = call noundef i32 %1(i32 noundef %2)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9Temporaryv() #0 {
entry:
  %ref.tmp = alloca %struct.Pair, align 4
  %first = getelementptr inbounds nuw %struct.Pair, ptr %ref.tmp, i32 0, i32 0
  store i32 0, ptr %first, align 4
  %second = getelementptr inbounds nuw %struct.Pair, ptr %ref.tmp, i32 0, i32 1
  store i32 0, ptr %second, align 4
  ret i32 0
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
!6 = !{i64 4}
!7 = !{i64 8}
