; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names -fno-rtti multiple_inheritance_layout.cpp -o -
; ModuleID = 'multiple_inheritance_layout.cpp'
source_filename = "multiple_inheritance_layout.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Small = type { i32 }
%struct.Wide = type { i64 }
%struct.Pair = type <{ %struct.Small, [4 x i8], %struct.Wide, i8, [7 x i8] }>
%struct.Spread = type { i8, [2 x i8] }
%struct.Count = type { i32 }
%struct.Shape = type <{ ptr, i32, [4 x i8] }>
%struct.Placed = type { %struct.Shape.base, %struct.Count, i32, [4 x i8] }
%struct.Shape.base = type <{ ptr, i32 }>
%struct.Padded = type <{ %struct.Head, i8, [3 x i8] }>
%struct.Head = type { i32 }
%struct.Byte = type { i8 }
%struct.Packed = type { %struct.Padded.base, %struct.Byte, i8, i8 }
%struct.Padded.base = type <{ %struct.Head, i8 }>
%struct.Point = type { i32 }
%struct.Twice = type { %struct.First, %struct.Second, i32 }
%struct.First = type { %struct.Point }
%struct.Second = type { %struct.Point }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z8ReadPairRK4Pair(ptr noundef nonnull align 8 dereferenceable(17) %pair) #0 {
entry:
  %pair.addr = alloca ptr, align 8
  store ptr %pair, ptr %pair.addr, align 8
  %0 = load ptr, ptr %pair.addr, align 8, !nonnull !5, !align !6
  %a = getelementptr inbounds nuw %struct.Small, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %a, align 8
  %conv = sext i32 %1 to i64
  %2 = load ptr, ptr %pair.addr, align 8, !nonnull !5, !align !6
  %add.ptr = getelementptr inbounds i8, ptr %2, i64 8
  %b = getelementptr inbounds nuw %struct.Wide, ptr %add.ptr, i32 0, i32 0
  %3 = load i64, ptr %b, align 8
  %add = add nsw i64 %conv, %3
  %4 = load ptr, ptr %pair.addr, align 8, !nonnull !5, !align !6
  %c = getelementptr inbounds nuw %struct.Pair, ptr %4, i32 0, i32 3
  %5 = load i8, ptr %c, align 8
  %conv1 = zext i8 %5 to i64
  %add2 = add nsw i64 %add, %conv1
  ret i64 %add2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z10ThirdEmptyR6Spread(ptr noundef nonnull align 1 dereferenceable(3) %spread) #0 {
entry:
  %spread.addr = alloca ptr, align 8
  store ptr %spread, ptr %spread.addr, align 8
  %0 = load ptr, ptr %spread.addr, align 8, !nonnull !5
  %1 = icmp eq ptr %0, null
  br i1 %1, label %cast.end, label %cast.notnull

cast.notnull:                                     ; preds = %entry
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 2
  br label %cast.end

cast.end:                                         ; preds = %cast.notnull, %entry
  %cast.result = phi ptr [ %add.ptr, %cast.notnull ], [ null, %entry ]
  ret ptr %cast.result
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z10ReadSpreadRK6Spread(ptr noundef nonnull align 1 dereferenceable(3) %spread) #0 {
entry:
  %spread.addr = alloca ptr, align 8
  store ptr %spread, ptr %spread.addr, align 8
  %0 = load ptr, ptr %spread.addr, align 8, !nonnull !5
  %d = getelementptr inbounds nuw %struct.Spread, ptr %0, i32 0, i32 0
  %1 = load i8, ptr %d, align 1
  ret i8 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z10ReadPlacedRK6Placed(ptr noundef nonnull align 8 dereferenceable(20) %placed) #0 {
entry:
  %placed.addr = alloca ptr, align 8
  store ptr %placed, ptr %placed.addr, align 8
  %0 = load ptr, ptr %placed.addr, align 8, !nonnull !5, !align !6
  %add.ptr = getelementptr inbounds i8, ptr %0, i64 12
  %a = getelementptr inbounds nuw %struct.Count, ptr %add.ptr, i32 0, i32 0
  %1 = load i32, ptr %a, align 4
  %2 = load ptr, ptr %placed.addr, align 8, !nonnull !5, !align !6
  %e = getelementptr inbounds nuw %struct.Shape, ptr %2, i32 0, i32 1
  %3 = load i32, ptr %e, align 8
  %add = add nsw i32 %1, %3
  %4 = load ptr, ptr %placed.addr, align 8, !nonnull !5, !align !6
  %f = getelementptr inbounds nuw %struct.Placed, ptr %4, i32 0, i32 2
  %5 = load i32, ptr %f, align 8
  %add1 = add nsw i32 %add, %5
  ret i32 %add1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z10ReadPackedRK6Packed(ptr noundef nonnull align 4 dereferenceable(7) %packed) #0 {
entry:
  %packed.addr = alloca ptr, align 8
  store ptr %packed, ptr %packed.addr, align 8
  %0 = load ptr, ptr %packed.addr, align 8, !nonnull !5, !align !7
  %h = getelementptr inbounds nuw %struct.Padded, ptr %0, i32 0, i32 1
  %1 = load i8, ptr %h, align 4
  %conv = zext i8 %1 to i32
  %2 = load ptr, ptr %packed.addr, align 8, !nonnull !5, !align !7
  %add.ptr = getelementptr inbounds i8, ptr %2, i64 5
  %i = getelementptr inbounds nuw %struct.Byte, ptr %add.ptr, i32 0, i32 0
  %3 = load i8, ptr %i, align 1
  %conv1 = zext i8 %3 to i32
  %add = add nsw i32 %conv, %conv1
  %4 = load ptr, ptr %packed.addr, align 8, !nonnull !5, !align !7
  %j = getelementptr inbounds nuw %struct.Packed, ptr %4, i32 0, i32 2
  %5 = load i8, ptr %j, align 2
  %conv2 = zext i8 %5 to i32
  %add3 = add nsw i32 %add, %conv2
  %conv4 = trunc i32 %add3 to i8
  ret i8 %conv4
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z9ReadTwiceRK5Twice(ptr noundef nonnull align 4 dereferenceable(12) %twice) #0 {
entry:
  %twice.addr = alloca ptr, align 8
  store ptr %twice, ptr %twice.addr, align 8
  %0 = load ptr, ptr %twice.addr, align 8, !nonnull !5, !align !7
  %x = getelementptr inbounds nuw %struct.Point, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %x, align 4
  %2 = load ptr, ptr %twice.addr, align 8, !nonnull !5, !align !7
  %add.ptr = getelementptr inbounds i8, ptr %2, i64 4
  %x1 = getelementptr inbounds nuw %struct.Point, ptr %add.ptr, i32 0, i32 0
  %3 = load i32, ptr %x1, align 4
  %add = add nsw i32 %1, %3
  %4 = load ptr, ptr %twice.addr, align 8, !nonnull !5, !align !7
  %y = getelementptr inbounds nuw %struct.Twice, ptr %4, i32 0, i32 2
  %5 = load i32, ptr %y, align 4
  %add2 = add nsw i32 %add, %5
  ret i32 %add2
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 4]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.5"}
!5 = !{}
!6 = !{i64 8}
!7 = !{i64 4}
