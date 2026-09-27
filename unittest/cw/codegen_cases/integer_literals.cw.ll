define noundef i64 @SignedLiteral() {
entry:
  %.result = alloca i64, align 8
  store i64 2147483648, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @UnsignedLiteral() {
entry:
  %.result = alloca i64, align 8
  store i64 -1, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @MinimumLiteral() {
entry:
  %.result = alloca i64, align 8
  store i64 -9223372036854775808, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef zeroext i16 @CharacterValue() {
entry:
  %.result = alloca i16, align 2
  store i16 255, ptr %.result, align 2
  %0 = load i16, ptr %.result, align 2
  ret i16 %0
}

define noundef zeroext i8 @CharacterArithmetic() {
entry:
  %.result = alloca i8, align 1
  store i8 0, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define noundef zeroext i8 @TruncatedLiteral() {
entry:
  %.result = alloca i8, align 1
  store i8 1, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define noundef i64 @NegativeUnsignedLiteral() {
entry:
  %.result = alloca i64, align 8
  store i64 -1, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @InferredLiteral() {
entry:
  %.result = alloca i64, align 8
  %value = alloca i64, align 8
  store i64 -9223372036854775808, ptr %value, align 8
  %0 = load i64, ptr %value, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}
