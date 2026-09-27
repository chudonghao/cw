define noundef signext i8 @SignedByteArithmetic(i8 noundef signext %left, i8 noundef signext %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  store i8 %left, ptr %left.addr, align 1
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %1 = load i8, ptr %right.addr, align 1
  %sub = sub i8 0, %1
  %add = add i8 %0, %sub
  %2 = load i8, ptr %left.addr, align 1
  %3 = load i8, ptr %right.addr, align 1
  %sub1 = sub i8 %2, %3
  %mul = mul i8 %add, %sub1
  store i8 %mul, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  ret i8 %4
}

define noundef zeroext i16 @UnsignedWordArithmetic(i16 noundef zeroext %left, i16 noundef zeroext %right) {
entry:
  %.result = alloca i16, align 2
  %left.addr = alloca i16, align 2
  %right.addr = alloca i16, align 2
  store i16 %left, ptr %left.addr, align 2
  store i16 %right, ptr %right.addr, align 2
  %0 = load i16, ptr %left.addr, align 2
  %1 = load i16, ptr %right.addr, align 2
  %add = add i16 %0, %1
  %2 = load i16, ptr %left.addr, align 2
  %3 = load i16, ptr %right.addr, align 2
  %sub = sub i16 %2, %3
  %mul = mul i16 %add, %sub
  store i16 %mul, ptr %.result, align 2
  %4 = load i16, ptr %.result, align 2
  ret i16 %4
}

define noundef i64 @UnsignedWideArithmetic(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %add = add i64 %0, %1
  %2 = load i64, ptr %left.addr, align 8
  %3 = load i64, ptr %right.addr, align 8
  %sub = sub i64 %2, %3
  %mul = mul i64 %add, %sub
  store i64 %mul, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef i64 @SignedWideNegate(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %sub = sub i64 0, %0
  store i64 %sub, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i32 @MixedArithmetic(i8 noundef signext %left, i16 noundef zeroext %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca i8, align 1
  %right.addr = alloca i16, align 2
  store i8 %left, ptr %left.addr, align 1
  store i16 %right, ptr %right.addr, align 2
  %0 = load i8, ptr %left.addr, align 1
  %conv = sext i8 %0 to i16
  %1 = load i16, ptr %right.addr, align 2
  %add = add i16 %conv, %1
  %conv1 = zext i16 %add to i32
  store i32 %conv1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i64 @SizeArithmetic(i64 noundef %left, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca i64, align 8
  %right.addr = alloca i64, align 8
  store i64 %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %left.addr, align 8
  %1 = load i64, ptr %right.addr, align 8
  %add = add i64 %0, %1
  store i64 %add, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}
