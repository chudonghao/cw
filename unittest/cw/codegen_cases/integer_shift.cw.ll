define noundef signext i8 @"cw:SignedByte:func(i8,u64)i8"(i8 noundef signext %left, i64 noundef %count) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %count.addr = alloca i64, align 8
  store i8 %left, ptr %left.addr, align 1
  store i64 %count, ptr %count.addr, align 8
  %0 = load i8, ptr %left.addr, align 1
  %1 = load i64, ptr %count.addr, align 8
  %shift.count = and i64 %1, 7
  %shift.cast = trunc i64 %shift.count to i8
  %shl = shl i8 %0, %shift.cast
  store i8 %shl, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef zeroext i8 @"cw:UnsignedByte:func(u8,i64)u8"(i8 noundef zeroext %left, i64 noundef %count) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %count.addr = alloca i64, align 8
  store i8 %left, ptr %left.addr, align 1
  store i64 %count, ptr %count.addr, align 8
  %0 = load i8, ptr %left.addr, align 1
  %1 = load i64, ptr %count.addr, align 8
  %shift.count = and i64 %1, 7
  %shift.cast = trunc i64 %shift.count to i8
  %lshr = lshr i8 %0, %shift.cast
  store i8 %lshr, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef signext i8 @"cw:SignedByteRight:func(i8,i64)i8"(i8 noundef signext %left, i64 noundef %count) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %count.addr = alloca i64, align 8
  store i8 %left, ptr %left.addr, align 1
  store i64 %count, ptr %count.addr, align 8
  %0 = load i8, ptr %left.addr, align 1
  %1 = load i64, ptr %count.addr, align 8
  %shift.count = and i64 %1, 7
  %shift.cast = trunc i64 %shift.count to i8
  %ashr = ashr i8 %0, %shift.cast
  store i8 %ashr, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef signext i16 @"cw:SignedWord:func(i16,u8)i16"(i16 noundef signext %left, i8 noundef zeroext %count) {
entry:
  %.result = alloca i16, align 2
  %left.addr = alloca i16, align 2
  %count.addr = alloca i8, align 1
  store i16 %left, ptr %left.addr, align 2
  store i8 %count, ptr %count.addr, align 1
  %0 = load i16, ptr %left.addr, align 2
  %1 = load i8, ptr %count.addr, align 1
  %shift.count = and i8 %1, 15
  %shift.cast = zext i8 %shift.count to i16
  %shl = shl i16 %0, %shift.cast
  store i16 %shl, ptr %.result, align 2
  %2 = load i16, ptr %.result, align 2
  ret i16 %2
}

define noundef zeroext i16 @"cw:UnsignedWord:func(u16,i8)u16"(i16 noundef zeroext %left, i8 noundef signext %count) {
entry:
  %.result = alloca i16, align 2
  %left.addr = alloca i16, align 2
  %count.addr = alloca i8, align 1
  store i16 %left, ptr %left.addr, align 2
  store i8 %count, ptr %count.addr, align 1
  %0 = load i16, ptr %left.addr, align 2
  %1 = load i8, ptr %count.addr, align 1
  %shift.count = and i8 %1, 15
  %shift.cast = zext i8 %shift.count to i16
  %lshr = lshr i16 %0, %shift.cast
  store i16 %lshr, ptr %.result, align 2
  %2 = load i16, ptr %.result, align 2
  ret i16 %2
}

define noundef i32 @"cw:Signed32:func(i32,i64)i32"(i32 noundef %left, i64 noundef %count) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca i32, align 4
  %count.addr = alloca i64, align 8
  store i32 %left, ptr %left.addr, align 4
  store i64 %count, ptr %count.addr, align 8
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i64, ptr %count.addr, align 8
  %shift.count = and i64 %1, 31
  %shift.cast = trunc i64 %shift.count to i32
  %shl = shl i32 %0, %shift.cast
  store i32 %shl, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:Signed32Right:func(i32,u64)i32"(i32 noundef %left, i64 noundef %count) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca i32, align 4
  %count.addr = alloca i64, align 8
  store i32 %left, ptr %left.addr, align 4
  store i64 %count, ptr %count.addr, align 8
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i64, ptr %count.addr, align 8
  %shift.count = and i64 %1, 31
  %shift.cast = trunc i64 %shift.count to i32
  %ashr = ashr i32 %0, %shift.cast
  store i32 %ashr, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:Unsigned32:func(u32,i16)u32"(i32 noundef %left, i16 noundef signext %count) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca i32, align 4
  %count.addr = alloca i16, align 2
  store i32 %left, ptr %left.addr, align 4
  store i16 %count, ptr %count.addr, align 2
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i16, ptr %count.addr, align 2
  %shift.count = and i16 %1, 31
  %shift.cast = zext i16 %shift.count to i32
  %shl = shl i32 %0, %shift.cast
  store i32 %shl, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i64 @"cw:Signed64:func(i64,i8)i64"(i64 noundef %left, i8 noundef signext %count) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca i64, align 8
  %count.addr = alloca i8, align 1
  store i64 %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i8, ptr %count.addr, align 1
  %shift.count = and i8 %1, 63
  %shift.cast = zext i8 %shift.count to i64
  %ashr = ashr i64 %0, %shift.cast
  store i64 %ashr, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:Unsigned64:func(u64,u32)u64"(i64 noundef %left, i32 noundef %count) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca i64, align 8
  %count.addr = alloca i32, align 4
  store i64 %left, ptr %left.addr, align 8
  store i32 %count, ptr %count.addr, align 4
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i32, ptr %count.addr, align 4
  %shift.count = and i32 %1, 63
  %shift.cast = zext i32 %shift.count to i64
  %shl = shl i64 %0, %shift.cast
  store i64 %shl, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:Size:func(isize,i32)isize"(i64 noundef %left, i32 noundef %count) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca i64, align 8
  %count.addr = alloca i32, align 4
  store i64 %left, ptr %left.addr, align 8
  store i32 %count, ptr %count.addr, align 4
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i32, ptr %count.addr, align 4
  %shift.count = and i32 %1, 63
  %shift.cast = zext i32 %shift.count to i64
  %ashr = ashr i64 %0, %shift.cast
  store i64 %ashr, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:UnsignedSize:func(usize,u8)usize"(i64 noundef %left, i8 noundef zeroext %count) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca i64, align 8
  %count.addr = alloca i8, align 1
  store i64 %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i8, ptr %count.addr, align 1
  %shift.count = and i8 %1, 63
  %shift.cast = zext i8 %shift.count to i64
  %shl = shl i64 %0, %shift.cast
  store i64 %shl, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef zeroext i8 @"cw:FixedBySize:func(u8,usize)u8"(i8 noundef zeroext %left, i64 noundef %count) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %count.addr = alloca i64, align 8
  store i8 %left, ptr %left.addr, align 1
  store i64 %count, ptr %count.addr, align 8
  %0 = load i8, ptr %left.addr, align 1
  %1 = load i64, ptr %count.addr, align 8
  %shift.count = and i64 %1, 7
  %shift.cast = trunc i64 %shift.count to i8
  %shl = shl i8 %0, %shift.cast
  store i8 %shl, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef i32 @"cw:ShiftBeforeWidening:func(u8)i32"(i8 noundef zeroext %left) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca i8, align 1
  store i8 %left, ptr %left.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %shl = shl i8 %0, 1
  %conv = zext i8 %shl to i32
  store i32 %conv, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:Literal32:func(u64)i32"(i64 noundef %count) {
entry:
  %.result = alloca i32, align 4
  %count.addr = alloca i64, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  %shift.count = and i64 %0, 31
  %shift.cast = trunc i64 %shift.count to i32
  %shl = shl i32 1, %shift.cast
  store i32 %shl, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:FoldedWideCount:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 1, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:FoldedNegativeCount:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 0, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:FoldedNegativeLeft:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 -6, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:FoldedSignBit:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 -2147483648, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:FoldedLostBits:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 0, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
