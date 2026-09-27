define noundef i32 @IntegerArithmetic(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i32, ptr %right.addr, align 4
  %sub = sub i32 0, %1
  %add = add i32 %0, %sub
  %2 = load i32, ptr %left.addr, align 4
  %3 = load i32, ptr %right.addr, align 4
  %sub1 = sub i32 %2, %3
  %mul = mul i32 %add, %sub1
  store i32 %mul, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @AddWrap() {
entry:
  %.result = alloca i32, align 4
  store i32 -2147483648, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @SubtractWrap() {
entry:
  %.result = alloca i32, align 4
  store i32 2147483647, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @MultiplyWrap() {
entry:
  %.result = alloca i32, align 4
  store i32 0, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @NegateMinimum() {
entry:
  %.result = alloca i32, align 4
  store i32 -2147483648, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
