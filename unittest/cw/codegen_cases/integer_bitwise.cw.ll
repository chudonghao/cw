define noundef zeroext i8 @"cw:UnsignedByte:func(u8,u8)u8"(i8 noundef zeroext %left, i8 noundef zeroext %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  store i8 %left, ptr %left.addr, align 1
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %1 = xor i8 %0, -1
  %2 = load i8, ptr %right.addr, align 1
  %and = and i8 %1, %2
  %3 = load i8, ptr %left.addr, align 1
  %4 = load i8, ptr %right.addr, align 1
  %xor = xor i8 %3, %4
  %or = or i8 %and, %xor
  store i8 %or, ptr %.result, align 1
  %5 = load i8, ptr %.result, align 1
  ret i8 %5
}

define noundef signext i8 @"cw:SignedByte:func(i8,i8)i8"(i8 noundef signext %left, i8 noundef signext %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  store i8 %left, ptr %left.addr, align 1
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %1 = xor i8 %0, -1
  %2 = load i8, ptr %right.addr, align 1
  %and = and i8 %1, %2
  %3 = load i8, ptr %left.addr, align 1
  %4 = load i8, ptr %right.addr, align 1
  %xor = xor i8 %3, %4
  %or = or i8 %and, %xor
  store i8 %or, ptr %.result, align 1
  %5 = load i8, ptr %.result, align 1
  ret i8 %5
}

define noundef zeroext i16 @"cw:Word:func(u16,u16)u16"(i16 noundef zeroext %left, i16 noundef zeroext %right) {
entry:
  %.result = alloca i16, align 2
  %left.addr = alloca i16, align 2
  %right.addr = alloca i16, align 2
  store i16 %left, ptr %left.addr, align 2
  store i16 %right, ptr %right.addr, align 2
  %0 = load i16, ptr %left.addr, align 2
  %1 = xor i16 %0, -1
  %2 = load i16, ptr %right.addr, align 2
  %and = and i16 %1, %2
  %3 = load i16, ptr %left.addr, align 2
  %4 = load i16, ptr %right.addr, align 2
  %xor = xor i16 %3, %4
  %or = or i16 %and, %xor
  store i16 %or, ptr %.result, align 2
  %5 = load i16, ptr %.result, align 2
  ret i16 %5
}

define noundef i32 @"cw:SignedWord:func(i32,i32)i32"(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = xor i32 %0, -1
  %2 = load i32, ptr %right.addr, align 4
  %and = and i32 %1, %2
  %3 = load i32, ptr %left.addr, align 4
  %4 = load i32, ptr %right.addr, align 4
  %xor = xor i32 %3, %4
  %or = or i32 %and, %xor
  store i32 %or, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define noundef i64 @"cw:Wide:func(u64,u64)u64"(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = xor i64 %0, -1
  %2 = load i64, ptr %right.addr, align 8
  %and = and i64 %1, %2
  %3 = load i64, ptr %left.addr, align 8
  %4 = load i64, ptr %right.addr, align 8
  %xor = xor i64 %3, %4
  %or = or i64 %and, %xor
  store i64 %or, ptr %.result, align 8
  %5 = load i64, ptr %.result, align 8
  ret i64 %5
}

define noundef zeroext i16 @"cw:Mixed:func(i8,u16)u16"(i8 noundef signext %left, i16 noundef zeroext %right) {
entry:
  %.result = alloca i16, align 2
  %left.addr = alloca i8, align 1
  %right.addr = alloca i16, align 2
  store i8 %left, ptr %left.addr, align 1
  store i16 %right, ptr %right.addr, align 2
  %0 = load i8, ptr %left.addr, align 1
  %conv = sext i8 %0 to i16
  %1 = load i16, ptr %right.addr, align 2
  %and = and i16 %conv, %1
  store i16 %and, ptr %.result, align 2
  %2 = load i16, ptr %.result, align 2
  ret i16 %2
}

define noundef i64 @"cw:Size:func(isize,usize)usize"(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = xor i64 %0, -1
  %2 = load i64, ptr %right.addr, align 8
  %and = and i64 %1, %2
  store i64 %and, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef i32 @"cw:InvertBeforeWidening:func(u8)i32"(i8 noundef zeroext %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %1 = xor i8 %0, -1
  %conv = zext i8 %1 to i32
  %and = and i32 %conv, 256
  store i32 %and, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i64 @"cw:FoldedSigned:func()i64"() {
entry:
  %.result = alloca i64, align 8
  store i64 -2147483649, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @"cw:FoldedUnsigned:func()u64"() {
entry:
  %.result = alloca i64, align 8
  store i64 0, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}
