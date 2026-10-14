define noundef signext i8 @"cw:Signed8:func(i8)i8"(i8 noundef signext %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  store i8 %0, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

define noundef zeroext i8 @"cw:Unsigned8:func(u8)u8"(i8 noundef zeroext %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  store i8 %0, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

define noundef signext i16 @"cw:Signed16:func(i16)i16"(i16 noundef signext %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca i16, align 2
  store i16 %value, ptr %value.addr, align 2
  %0 = load i16, ptr %value.addr, align 2
  store i16 %0, ptr %.result, align 2
  %1 = load i16, ptr %.result, align 2
  ret i16 %1
}

define noundef zeroext i16 @"cw:Unsigned16:func(u16)u16"(i16 noundef zeroext %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca i16, align 2
  store i16 %value, ptr %value.addr, align 2
  %0 = load i16, ptr %value.addr, align 2
  store i16 %0, ptr %.result, align 2
  %1 = load i16, ptr %.result, align 2
  ret i16 %1
}

define noundef i32 @"cw:Signed32:func(i32)i32"(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:Unsigned32:func(u32)u32"(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i64 @"cw:Signed64:func(i64)i64"(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @"cw:Unsigned64:func(u64)u64"(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @"cw:SignedSize:func(isize)isize"(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @"cw:UnsignedSize:func(usize)usize"(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef signext i8 @"cw:ForwardSigned8:func(i8)i8"(i8 noundef signext %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %call = call noundef signext i8 @"cw:Signed8:func(i8)i8"(i8 noundef signext %0)
  store i8 %call, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

define noundef zeroext i8 @"cw:ForwardUnsigned8:func(u8)u8"(i8 noundef zeroext %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %call = call noundef zeroext i8 @"cw:Unsigned8:func(u8)u8"(i8 noundef zeroext %0)
  store i8 %call, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

define noundef signext i16 @"cw:ForwardSigned16:func(i16)i16"(i16 noundef signext %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca i16, align 2
  store i16 %value, ptr %value.addr, align 2
  %0 = load i16, ptr %value.addr, align 2
  %call = call noundef signext i16 @"cw:Signed16:func(i16)i16"(i16 noundef signext %0)
  store i16 %call, ptr %.result, align 2
  %1 = load i16, ptr %.result, align 2
  ret i16 %1
}

define noundef zeroext i16 @"cw:ForwardUnsigned16:func(u16)u16"(i16 noundef zeroext %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca i16, align 2
  store i16 %value, ptr %value.addr, align 2
  %0 = load i16, ptr %value.addr, align 2
  %call = call noundef zeroext i16 @"cw:Unsigned16:func(u16)u16"(i16 noundef zeroext %0)
  store i16 %call, ptr %.result, align 2
  %1 = load i16, ptr %.result, align 2
  ret i16 %1
}

define noundef zeroext i8 @"cw:ForwardNarrow:func(i64)u8"(i64 noundef %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %conv = trunc i64 %0 to i8
  %call = call noundef zeroext i8 @"cw:Unsigned8:func(u8)u8"(i8 noundef zeroext %conv)
  store i8 %call, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}
