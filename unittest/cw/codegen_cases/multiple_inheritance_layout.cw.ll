%struct.Small = type { i32 }
%struct.Pair = type { %struct.Small, %struct.Wide, i8 }
%struct.Wide = type { i64 }
%struct.Spread = type { i8, [2 x i8] }
%struct.Placed = type { %struct.Shape.base, %struct.Count, i32, [4 x i8] }
%struct.Shape.base = type <{ ptr, i32 }>
%struct.Count = type { i32 }
%struct.Shape = type { ptr, i32 }
%struct.Padded = type { %struct.Head, i8 }
%struct.Head = type { i32 }
%struct.Packed = type { %struct.Padded.base, %struct.Byte, i8, i8 }
%struct.Padded.base = type <{ %struct.Head, i8 }>
%struct.Byte = type { i8 }
%struct.Point = type { i32 }
%struct.Twice = type { %struct.First, %struct.Second, i32 }
%struct.First = type { %struct.Point }
%struct.Second = type { %struct.Point }

declare noundef ptr @"cw:Count:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Count:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Shape:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Shape:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Placed:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Placed:dtor():base"(ptr noundef returned)

define noundef i64 @"cw:ReadPair:func(&copy Pair)i64"(ptr noundef nonnull align 8 dereferenceable(17) %pair) {
entry:
  %.result = alloca i64, align 8
  %pair.addr = alloca ptr, align 8
  store ptr %pair, ptr %pair.addr, align 8
  %0 = load ptr, ptr %pair.addr, align 8
  %a = getelementptr inbounds nuw %struct.Small, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %a, align 8
  %conv = sext i32 %1 to i64
  %2 = load ptr, ptr %pair.addr, align 8
  %base = getelementptr inbounds nuw %struct.Pair, ptr %2, i32 0, i32 1
  %b = getelementptr inbounds nuw %struct.Wide, ptr %base, i32 0, i32 0
  %3 = load i64, ptr %b, align 8
  %add = add i64 %conv, %3
  %4 = load ptr, ptr %pair.addr, align 8
  %c = getelementptr inbounds nuw %struct.Pair, ptr %4, i32 0, i32 2
  %5 = load i8, ptr %c, align 8
  %conv1 = zext i8 %5 to i64
  %add2 = add i64 %add, %conv1
  store i64 %add2, ptr %.result, align 8
  %6 = load i64, ptr %.result, align 8
  ret i64 %6
}

define noundef ptr @"cw:ThirdEmpty:func(&mut Spread)*Empty"(ptr noundef nonnull align 1 dereferenceable(3) %spread) {
entry:
  %.result = alloca ptr, align 8
  %spread.addr = alloca ptr, align 8
  store ptr %spread, ptr %spread.addr, align 8
  %0 = load ptr, ptr %spread.addr, align 8
  %base = getelementptr inbounds nuw i8, ptr %0, i64 2
  store ptr %base, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef zeroext i8 @"cw:ReadSpread:func(&copy Spread)u8"(ptr noundef nonnull align 1 dereferenceable(3) %spread) {
entry:
  %.result = alloca i8, align 1
  %spread.addr = alloca ptr, align 8
  store ptr %spread, ptr %spread.addr, align 8
  %0 = load ptr, ptr %spread.addr, align 8
  %d = getelementptr inbounds nuw %struct.Spread, ptr %0, i32 0, i32 0
  %1 = load i8, ptr %d, align 1
  store i8 %1, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef i32 @"cw:ReadPlaced:func(&copy Placed)i32"(ptr noundef nonnull align 8 dereferenceable(20) %placed) {
entry:
  %.result = alloca i32, align 4
  %placed.addr = alloca ptr, align 8
  store ptr %placed, ptr %placed.addr, align 8
  %0 = load ptr, ptr %placed.addr, align 8
  %base = getelementptr inbounds nuw %struct.Placed, ptr %0, i32 0, i32 1
  %a = getelementptr inbounds nuw %struct.Count, ptr %base, i32 0, i32 0
  %1 = load i32, ptr %a, align 4
  %2 = load ptr, ptr %placed.addr, align 8
  %e = getelementptr inbounds nuw %struct.Shape, ptr %2, i32 0, i32 1
  %3 = load i32, ptr %e, align 8
  %add = add i32 %1, %3
  %4 = load ptr, ptr %placed.addr, align 8
  %f = getelementptr inbounds nuw %struct.Placed, ptr %4, i32 0, i32 2
  %5 = load i32, ptr %f, align 8
  %add1 = add i32 %add, %5
  store i32 %add1, ptr %.result, align 4
  %6 = load i32, ptr %.result, align 4
  ret i32 %6
}

define noundef zeroext i8 @"cw:ReadPacked:func(&copy Packed)u8"(ptr noundef nonnull align 4 dereferenceable(7) %packed) {
entry:
  %.result = alloca i8, align 1
  %packed.addr = alloca ptr, align 8
  store ptr %packed, ptr %packed.addr, align 8
  %0 = load ptr, ptr %packed.addr, align 8
  %h = getelementptr inbounds nuw %struct.Padded, ptr %0, i32 0, i32 1
  %1 = load i8, ptr %h, align 4
  %2 = load ptr, ptr %packed.addr, align 8
  %base = getelementptr inbounds nuw %struct.Packed, ptr %2, i32 0, i32 1
  %i = getelementptr inbounds nuw %struct.Byte, ptr %base, i32 0, i32 0
  %3 = load i8, ptr %i, align 1
  %add = add i8 %1, %3
  %4 = load ptr, ptr %packed.addr, align 8
  %j = getelementptr inbounds nuw %struct.Packed, ptr %4, i32 0, i32 2
  %5 = load i8, ptr %j, align 2
  %add1 = add i8 %add, %5
  store i8 %add1, ptr %.result, align 1
  %6 = load i8, ptr %.result, align 1
  ret i8 %6
}

define noundef i32 @"cw:ReadTwice:func(&copy Twice)i32"(ptr noundef nonnull align 4 dereferenceable(12) %twice) {
entry:
  %.result = alloca i32, align 4
  %twice.addr = alloca ptr, align 8
  store ptr %twice, ptr %twice.addr, align 8
  %0 = load ptr, ptr %twice.addr, align 8
  %x = getelementptr inbounds nuw %struct.Point, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %x, align 4
  %2 = load ptr, ptr %twice.addr, align 8
  %base = getelementptr inbounds nuw %struct.Twice, ptr %2, i32 0, i32 1
  %x1 = getelementptr inbounds nuw %struct.Point, ptr %base, i32 0, i32 0
  %3 = load i32, ptr %x1, align 4
  %add = add i32 %1, %3
  %4 = load ptr, ptr %twice.addr, align 8
  %y = getelementptr inbounds nuw %struct.Twice, ptr %4, i32 0, i32 2
  %5 = load i32, ptr %y, align 4
  %add2 = add i32 %add, %5
  store i32 %add2, ptr %.result, align 4
  %6 = load i32, ptr %.result, align 4
  ret i32 %6
}
