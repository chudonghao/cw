define noundef i64 @SignExtend(i8 noundef signext %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %conv = sext i8 %0 to i64
  store i64 %conv, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @ZeroExtend(i8 noundef zeroext %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %conv = zext i8 %0 to i64
  store i64 %conv, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @SignExtendToUnsigned(i16 noundef signext %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i16, align 2
  store i16 %value, ptr %value.addr, align 2
  %0 = load i16, ptr %value.addr, align 2
  %conv = sext i16 %0 to i64
  store i64 %conv, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @UnsignedToSignedWide(i32 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %conv = zext i32 %0 to i64
  store i64 %conv, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef zeroext i8 @NarrowUnsigned(i64 noundef %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %conv = trunc i64 %0 to i8
  store i8 %conv, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

define noundef signext i16 @NarrowSigned(i64 noundef %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %conv = trunc i64 %0 to i16
  store i16 %conv, ptr %.result, align 2
  %1 = load i16, ptr %.result, align 2
  ret i16 %1
}

define noundef i32 @SameWidth(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i64 @SizeToUnsigned(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @SizeToSigned(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i32 @UnsignedAsSignedByte(i8 noundef zeroext %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i8, align 1
  %byte = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  store i8 %0, ptr %byte, align 1
  %1 = load i8, ptr %byte, align 1
  %conv = sext i8 %1 to i32
  store i32 %conv, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @SignedAsUnsignedByte(i8 noundef signext %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i8, align 1
  %byte = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  store i8 %0, ptr %byte, align 1
  %1 = load i8, ptr %byte, align 1
  %conv = zext i8 %1 to i32
  store i32 %conv, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}
