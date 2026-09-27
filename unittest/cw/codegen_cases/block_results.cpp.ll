; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names block_results.cpp -o -
; ModuleID = 'block_results.cpp'
source_filename = "block_results.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7ReplaceRi(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  store i32 71, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %1, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z12BlockResultsv() #0 {
entry:
  %result = alloca i32, align 4
  %source = alloca i32, align 4
  %first = alloca i32, align 4
  %second = alloca i32, align 4
  %block = alloca i32, align 4
  %forwarded = alloca i32, align 4
  %saved = alloca i32, align 4
  store i32 11, ptr %source, align 4
  %0 = load i32, ptr %source, align 4
  store i32 %0, ptr %first, align 4
  %call = call noundef i32 @_Z7ReplaceRi(ptr noundef nonnull align 4 dereferenceable(4) %source)
  store i32 %call, ptr %second, align 4
  %1 = load i32, ptr %first, align 4
  store i32 %1, ptr %saved, align 4
  %2 = load i32, ptr %saved, align 4
  store i32 %2, ptr %block, align 4
  %3 = load i32, ptr %block, align 4
  store i32 %3, ptr %forwarded, align 4
  %4 = load i32, ptr %forwarded, align 4
  store i32 %4, ptr %result, align 4
  %5 = load i32, ptr %result, align 4
  ret i32 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z13BranchResultsb(i1 noundef zeroext %flag) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %first = alloca i32, align 4
  %second = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  store i32 7, ptr %first, align 4
  %1 = load i32, ptr %first, align 4
  store i32 %1, ptr %second, align 4
  br label %if.end

if.else:                                          ; preds = %entry
  store i32 11, ptr %first, align 4
  %2 = load i32, ptr %first, align 4
  store i32 %2, ptr %second, align 4
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %3 = load i32, ptr %second, align 4
  ret i32 %3
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
