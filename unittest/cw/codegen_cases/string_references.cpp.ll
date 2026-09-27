; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names string_references.cpp -o -
; ModuleID = 'string_references.cpp'
source_filename = "string_references.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

@.str = private unnamed_addr constant [4 x i8] c"abc\00", align 1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 1 dereferenceable(4) ptr @_Z6Borrowv() #0 {
entry:
  ret ptr @.str
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z7Pointerv() #0 {
entry:
  ret ptr @.str
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z4ReadRA4_Kcm(ptr noundef nonnull align 1 dereferenceable(4) %value, i64 noundef %index) #0 {
entry:
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [4 x i8], ptr %0, i64 0, i64 %1
  %2 = load i8, ptr %arrayidx, align 1
  ret i8 %2
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z3Usem(i64 noundef %index) #1 {
entry:
  %index.addr = alloca i64, align 8
  %callback = alloca ptr, align 8
  store i64 %index, ptr %index.addr, align 8
  store ptr @_Z4ReadRA4_Kcm, ptr %callback, align 8
  %call = call noundef nonnull align 1 dereferenceable(4) ptr @_Z6Borrowv()
  %0 = load i64, ptr %index.addr, align 8
  %call1 = call noundef zeroext i8 @_Z4ReadRA4_Kcm(ptr noundef nonnull align 1 dereferenceable(4) %call, i64 noundef %0)
  %conv = zext i8 %call1 to i32
  %1 = load ptr, ptr %callback, align 8
  %call2 = call noundef ptr @_Z7Pointerv()
  %2 = load i64, ptr %index.addr, align 8
  %call3 = call noundef zeroext i8 %1(ptr noundef nonnull align 1 dereferenceable(4) %call2, i64 noundef %2)
  %conv4 = zext i8 %call3 to i32
  %add = add nsw i32 %conv, %conv4
  %3 = load i64, ptr %index.addr, align 8
  %call5 = call noundef zeroext i8 @_Z4ReadRA4_Kcm(ptr noundef nonnull align 1 dereferenceable(4) @.str, i64 noundef %3)
  %conv6 = zext i8 %call5 to i32
  %add7 = add nsw i32 %add, %conv6
  %conv8 = trunc i32 %add7 to i8
  ret i8 %conv8
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
