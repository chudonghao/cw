define noundef zeroext i1 @UnsignedEqual(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %cmp = icmp eq i64 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @UnsignedNotEqual(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %cmp = icmp ne i64 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @UnsignedLess(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %cmp = icmp ult i64 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @UnsignedLessEqual(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %cmp = icmp ule i64 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @UnsignedGreater(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %cmp = icmp ugt i64 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @UnsignedGreaterEqual(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %cmp = icmp uge i64 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @MixedUnsignedLess(i8 noundef signext %left, i16 noundef zeroext %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i16, align 2
  store i8 %left, ptr %left.addr, align 1
  store i16 %right, ptr %right.addr, align 2
  %0 = load i8, ptr %left.addr, align 1
  %conv = sext i8 %0 to i16
  %1 = load i16, ptr %right.addr, align 2
  %cmp = icmp ult i16 %conv, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @MixedSignedLess(i16 noundef signext %left, i8 noundef zeroext %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i16, align 2
  %right.addr = alloca i8, align 1
  store i16 %left, ptr %left.addr, align 2
  store i8 %right, ptr %right.addr, align 1
  %0 = load i16, ptr %left.addr, align 2
  %1 = load i8, ptr %right.addr, align 1
  %conv = zext i8 %1 to i16
  %cmp = icmp slt i16 %0, %conv
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @SameWidthLess(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i32, ptr %right.addr, align 4
  %cmp = icmp ult i32 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}
