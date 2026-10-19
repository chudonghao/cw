; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names bitwise_operators.cpp -o -
; ModuleID = 'bitwise_operators.cpp'
source_filename = "bitwise_operators.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%"struct.Api::Bits" = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3ApicoERKNS_4BitsE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %"struct.Api::Bits", ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  %not = xor i32 %1, -1
  ret i32 %not
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3ApianERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %"struct.Api::Bits", ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value1, align 4
  %and = and i32 %1, %3
  ret i32 %and
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3ApiorERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %"struct.Api::Bits", ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value1, align 4
  %or = or i32 %1, %3
  ret i32 %or
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3ApieoERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %"struct.Api::Bits", ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value1, align 4
  %xor = xor i32 %1, %3
  ret i32 %xor
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZN3Api11ExpressionsERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZN3ApicoERKNS_4BitsE(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_ZN3ApianERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  %add = add nsw i32 %call, %call1
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %4 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call2 = call noundef i32 @_ZN3ApiorERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %3, ptr noundef nonnull align 4 dereferenceable(4) %4)
  %add3 = add nsw i32 %add, %call2
  %5 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %6 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call4 = call noundef i32 @_ZN3ApieoERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %5, ptr noundef nonnull align 4 dereferenceable(4) %6)
  %add5 = add nsw i32 %add3, %call4
  ret i32 %add5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8ExplicitRKN3Api4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZN3ApicoERKNS_4BitsE(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %2 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 @_ZN3ApianERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  %add = add nsw i32 %call, %call1
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %4 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call2 = call noundef i32 @_ZN3ApiorERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %3, ptr noundef nonnull align 4 dereferenceable(4) %4)
  %add3 = add nsw i32 %add, %call2
  %5 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %6 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call4 = call noundef i32 @_ZN3ApieoERKNS_4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %5, ptr noundef nonnull align 4 dereferenceable(4) %6)
  %add5 = add nsw i32 %add3, %call4
  ret i32 %add5
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8IndirectRKN3Api4BitsES2_(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) #1 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %invert = alloca ptr, align 8
  %both = alloca ptr, align 8
  %either = alloca ptr, align 8
  %different = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  store ptr @_ZN3ApicoERKNS_4BitsE, ptr %invert, align 8
  store ptr @_ZN3ApianERKNS_4BitsES2_, ptr %both, align 8
  store ptr @_ZN3ApiorERKNS_4BitsES2_, ptr %either, align 8
  store ptr @_ZN3ApieoERKNS_4BitsES2_, ptr %different, align 8
  %0 = load ptr, ptr %invert, align 8
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %both, align 8
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %4 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call1 = call noundef i32 %2(ptr noundef nonnull align 4 dereferenceable(4) %3, ptr noundef nonnull align 4 dereferenceable(4) %4)
  %add = add nsw i32 %call, %call1
  %5 = load ptr, ptr %either, align 8
  %6 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %7 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call2 = call noundef i32 %5(ptr noundef nonnull align 4 dereferenceable(4) %6, ptr noundef nonnull align 4 dereferenceable(4) %7)
  %add3 = add nsw i32 %add, %call2
  %8 = load ptr, ptr %different, align 8
  %9 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %10 = load ptr, ptr %right.addr, align 8, !nonnull !5, !align !6
  %call4 = call noundef i32 %8(ptr noundef nonnull align 4 dereferenceable(4) %9, ptr noundef nonnull align 4 dereferenceable(4) %10)
  %add5 = add nsw i32 %add3, %call4
  ret i32 %add5
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
