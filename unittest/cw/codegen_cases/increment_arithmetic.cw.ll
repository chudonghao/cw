define noundef signext i8 @"cw:SignedByte:func(&mut i8)i8"(ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i8, ptr %0, align 1
  %add = add i8 %1, 1
  store i8 %add, ptr %0, align 1
  store i8 %1, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef zeroext i8 @"cw:UnsignedByte:func(&mut u8)u8"(ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i8, ptr %0, align 1
  %sub = sub i8 %1, 1
  store i8 %sub, ptr %0, align 1
  %2 = load i8, ptr %0, align 1
  store i8 %2, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  ret i8 %3
}

define noundef signext i16 @"cw:SignedShort:func(&mut i16)i16"(ptr noundef nonnull align 2 dereferenceable(2) %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i16, ptr %0, align 2
  %add = add i16 %1, 1
  store i16 %add, ptr %0, align 2
  %2 = load i16, ptr %0, align 2
  store i16 %2, ptr %.result, align 2
  %3 = load i16, ptr %.result, align 2
  ret i16 %3
}

define noundef zeroext i16 @"cw:UnsignedShort:func(&mut u16)u16"(ptr noundef nonnull align 2 dereferenceable(2) %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i16, ptr %0, align 2
  %sub = sub i16 %1, 1
  store i16 %sub, ptr %0, align 2
  store i16 %1, ptr %.result, align 2
  %2 = load i16, ptr %.result, align 2
  ret i16 %2
}

define noundef i32 @"cw:SignedInt:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %sub = sub i32 %1, 1
  store i32 %sub, ptr %0, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:UnsignedInt:func(&mut u32)u32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load i32, ptr %0, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i64 @"cw:SignedLong:func(&mut i64)i64"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %0, align 8
  %sub = sub i64 %1, 1
  store i64 %sub, ptr %0, align 8
  %2 = load i64, ptr %0, align 8
  store i64 %2, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef i64 @"cw:UnsignedLong:func(&mut u64)u64"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %0, align 8
  %add = add i64 %1, 1
  store i64 %add, ptr %0, align 8
  store i64 %1, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:SignedSize:func(&mut isize)isize"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %0, align 8
  %add = add i64 %1, 1
  store i64 %add, ptr %0, align 8
  %2 = load i64, ptr %0, align 8
  store i64 %2, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef i64 @"cw:UnsignedSize:func(&mut usize)usize"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %0, align 8
  %sub = sub i64 %1, 1
  store i64 %sub, ptr %0, align 8
  store i64 %1, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef float @"cw:Float32:func(&mut f32)f32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca float, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load float, ptr %0, align 4
  %add = fadd float %1, 1.000000e+00
  store float %add, ptr %0, align 4
  store float %1, ptr %.result, align 4
  %2 = load float, ptr %.result, align 4
  ret float %2
}

define noundef double @"cw:Float64:func(&mut f64)f64"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load double, ptr %0, align 8
  %sub = fsub double %1, 1.000000e+00
  store double %sub, ptr %0, align 8
  %2 = load double, ptr %0, align 8
  store double %2, ptr %.result, align 8
  %3 = load double, ptr %.result, align 8
  ret double %3
}
