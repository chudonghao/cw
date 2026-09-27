; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names operator_calls.cpp -o -
; ModuleID = 'operator_calls.cpp'
source_filename = "operator_calls.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Number = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZngRK6Number(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %value1 = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  %sub = sub nsw i32 0, %1
  ret i32 %sub
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_ZmiRK6Numbers(ptr noundef nonnull align 4 dereferenceable(4) %left, i16 noundef signext %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i16, align 2
  store ptr %left, ptr %left.addr, align 8
  store i16 %right, ptr %right.addr, align 2
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %value = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load i16, ptr %right.addr, align 2
  %conv = sext i16 %2 to i32
  %sub = sub nsw i32 %1, %conv
  ret i32 %sub
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z5UnaryRK6Number(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef i32 @_ZngRK6Number(ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z6BinaryRK6Numbera(ptr noundef nonnull align 4 dereferenceable(4) %value, i8 noundef signext %amount) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %amount.addr = alloca i8, align 1
  store ptr %value, ptr %value.addr, align 8
  store i8 %amount, ptr %amount.addr, align 1
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i8, ptr %amount.addr, align 1
  %conv = sext i8 %1 to i16
  %call = call noundef i32 @_ZmiRK6Numbers(ptr noundef nonnull align 4 dereferenceable(4) %0, i16 noundef signext %conv)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8ExplicitRK6Numbers(ptr noundef nonnull align 4 dereferenceable(4) %value, i16 noundef signext %amount) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %amount.addr = alloca i16, align 2
  store ptr %value, ptr %value.addr, align 8
  store i16 %amount, ptr %amount.addr, align 2
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i16, ptr %amount.addr, align 2
  %call = call noundef i32 @_ZmiRK6Numbers(ptr noundef nonnull align 4 dereferenceable(4) %0, i16 noundef signext %1)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8IndirectRK6Numbers(ptr noundef nonnull align 4 dereferenceable(4) %value, i16 noundef signext %amount) #1 {
entry:
  %value.addr = alloca ptr, align 8
  %amount.addr = alloca i16, align 2
  %operation = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store i16 %amount, ptr %amount.addr, align 2
  store ptr @_ZmiRK6Numbers, ptr %operation, align 8
  %0 = load ptr, ptr %operation, align 8
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load i16, ptr %amount.addr, align 2
  %call = call noundef i32 %0(ptr noundef nonnull align 4 dereferenceable(4) %1, i16 noundef signext %2)
  ret i32 %call
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
