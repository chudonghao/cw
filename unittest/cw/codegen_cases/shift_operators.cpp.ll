; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names shift_operators.cpp -o -
; ModuleID = 'shift_operators.cpp'
source_filename = "shift_operators.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%"struct.Api::Bits" = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_ZN3ApilsERKNS_4BitsEx(ptr noundef nonnull align 4 dereferenceable(4) %left, i64 noundef %count) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  ret i64 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApirsERNS_4BitsEi(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %count) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %count, ptr %count.addr, align 4
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_ZN3Api11ExpressionsERNS_4BitsEa(ptr noundef nonnull align 4 dereferenceable(4) %left, i8 noundef signext %count) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %1 = load i8, ptr %count.addr, align 1
  %conv = sext i8 %1 to i32
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApirsERNS_4BitsEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %conv)
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %call, i32 0, i32 0
  store i32 7, ptr %value, align 4
  %2 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %3 = load i8, ptr %count.addr, align 1
  %conv1 = sext i8 %3 to i64
  %call2 = call noundef i64 @_ZN3ApilsERKNS_4BitsEx(ptr noundef nonnull align 4 dereferenceable(4) %2, i64 noundef %conv1)
  ret i64 %call2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z8ExplicitRN3Api4BitsEa(ptr noundef nonnull align 4 dereferenceable(4) %left, i8 noundef signext %count) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %1 = load i8, ptr %count.addr, align 1
  %conv = sext i8 %1 to i32
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApirsERNS_4BitsEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %conv)
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %call, i32 0, i32 0
  store i32 7, ptr %value, align 4
  %2 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %3 = load i8, ptr %count.addr, align 1
  %conv1 = sext i8 %3 to i64
  %call2 = call noundef i64 @_ZN3ApilsERKNS_4BitsEx(ptr noundef nonnull align 4 dereferenceable(4) %2, i64 noundef %conv1)
  ret i64 %call2
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z8IndirectRN3Api4BitsEa(ptr noundef nonnull align 4 dereferenceable(4) %left, i8 noundef signext %count) #1 {
entry:
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i8, align 1
  %shl = alloca ptr, align 8
  %shr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  store ptr @_ZN3ApilsERKNS_4BitsEx, ptr %shl, align 8
  store ptr @_ZN3ApirsERNS_4BitsEi, ptr %shr, align 8
  %0 = load ptr, ptr %shr, align 8
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %2 = load i8, ptr %count.addr, align 1
  %conv = sext i8 %2 to i32
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1, i32 noundef %conv)
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %call, i32 0, i32 0
  store i32 7, ptr %value, align 4
  %3 = load ptr, ptr %shl, align 8
  %4 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %5 = load i8, ptr %count.addr, align 1
  %conv1 = sext i8 %5 to i64
  %call2 = call noundef i64 %3(ptr noundef nonnull align 4 dereferenceable(4) %4, i64 noundef %conv1)
  ret i64 %call2
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
