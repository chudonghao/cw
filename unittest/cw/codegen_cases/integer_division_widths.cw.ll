define noundef signext i8 @"cw:ByteQuotient:func(i8,i8)i8"(i8 noundef signext %dividend, i8 noundef signext %divisor) {
entry:
  %.result = alloca i8, align 1
  %dividend.addr = alloca i8, align 1
  %divisor.addr = alloca i8, align 1
  store i8 %dividend, ptr %dividend.addr, align 1
  store i8 %divisor, ptr %divisor.addr, align 1
  %0 = load i8, ptr %dividend.addr, align 1
  %1 = load i8, ptr %divisor.addr, align 1
  %2 = icmp eq i8 %1, -1
  br i1 %2, label %div.negone, label %div.normal

div.negone:                                       ; preds = %entry
  %sub = sub i8 0, %0
  br label %div.end

div.normal:                                       ; preds = %entry
  %div = sdiv i8 %0, %1
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div1 = phi i8 [ %sub, %div.negone ], [ %div, %div.normal ]
  store i8 %div1, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  ret i8 %3
}

define noundef signext i8 @"cw:ByteRemainder:func(i8,i8)i8"(i8 noundef signext %dividend, i8 noundef signext %divisor) {
entry:
  %.result = alloca i8, align 1
  %dividend.addr = alloca i8, align 1
  %divisor.addr = alloca i8, align 1
  store i8 %dividend, ptr %dividend.addr, align 1
  store i8 %divisor, ptr %divisor.addr, align 1
  %0 = load i8, ptr %dividend.addr, align 1
  %1 = load i8, ptr %divisor.addr, align 1
  %2 = icmp eq i8 %1, -1
  br i1 %2, label %rem.negone, label %rem.normal

rem.negone:                                       ; preds = %entry
  br label %rem.end

rem.normal:                                       ; preds = %entry
  %rem = srem i8 %0, %1
  br label %rem.end

rem.end:                                          ; preds = %rem.normal, %rem.negone
  %rem1 = phi i8 [ 0, %rem.negone ], [ %rem, %rem.normal ]
  store i8 %rem1, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  ret i8 %3
}

define noundef signext i16 @"cw:WordQuotient:func(i16,i16)i16"(i16 noundef signext %dividend, i16 noundef signext %divisor) {
entry:
  %.result = alloca i16, align 2
  %dividend.addr = alloca i16, align 2
  %divisor.addr = alloca i16, align 2
  store i16 %dividend, ptr %dividend.addr, align 2
  store i16 %divisor, ptr %divisor.addr, align 2
  %0 = load i16, ptr %dividend.addr, align 2
  %1 = load i16, ptr %divisor.addr, align 2
  %2 = icmp eq i16 %1, -1
  br i1 %2, label %div.negone, label %div.normal

div.negone:                                       ; preds = %entry
  %sub = sub i16 0, %0
  br label %div.end

div.normal:                                       ; preds = %entry
  %div = sdiv i16 %0, %1
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div1 = phi i16 [ %sub, %div.negone ], [ %div, %div.normal ]
  store i16 %div1, ptr %.result, align 2
  %3 = load i16, ptr %.result, align 2
  ret i16 %3
}

define noundef i64 @"cw:WideRemainder:func(i64,i64)i64"(i64 noundef %dividend, i64 noundef %divisor) {
entry:
  %.result = alloca i64, align 8
  %dividend.addr = alloca i64, align 8
  %divisor.addr = alloca i64, align 8
  store i64 %dividend, ptr %dividend.addr, align 8
  store i64 %divisor, ptr %divisor.addr, align 8
  %0 = load i64, ptr %dividend.addr, align 8
  %1 = load i64, ptr %divisor.addr, align 8
  %2 = icmp eq i64 %1, -1
  br i1 %2, label %rem.negone, label %rem.normal

rem.negone:                                       ; preds = %entry
  br label %rem.end

rem.normal:                                       ; preds = %entry
  %rem = srem i64 %0, %1
  br label %rem.end

rem.end:                                          ; preds = %rem.normal, %rem.negone
  %rem1 = phi i64 [ 0, %rem.negone ], [ %rem, %rem.normal ]
  store i64 %rem1, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef i64 @"cw:SizeQuotient:func(isize,isize)isize"(i64 noundef %dividend, i64 noundef %divisor) {
entry:
  %.result = alloca i64, align 8
  %dividend.addr = alloca i64, align 8
  %divisor.addr = alloca i64, align 8
  store i64 %dividend, ptr %dividend.addr, align 8
  store i64 %divisor, ptr %divisor.addr, align 8
  %0 = load i64, ptr %dividend.addr, align 8
  %1 = load i64, ptr %divisor.addr, align 8
  %2 = icmp eq i64 %1, -1
  br i1 %2, label %div.negone, label %div.normal

div.negone:                                       ; preds = %entry
  %sub = sub i64 0, %0
  br label %div.end

div.normal:                                       ; preds = %entry
  %div = sdiv i64 %0, %1
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div1 = phi i64 [ %sub, %div.negone ], [ %div, %div.normal ]
  store i64 %div1, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef zeroext i8 @"cw:UnsignedByteQuotient:func(u8,u8)u8"(i8 noundef zeroext %dividend, i8 noundef zeroext %divisor) {
entry:
  %.result = alloca i8, align 1
  %dividend.addr = alloca i8, align 1
  %divisor.addr = alloca i8, align 1
  store i8 %dividend, ptr %dividend.addr, align 1
  store i8 %divisor, ptr %divisor.addr, align 1
  %0 = load i8, ptr %dividend.addr, align 1
  %1 = load i8, ptr %divisor.addr, align 1
  %div = udiv i8 %0, %1
  store i8 %div, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef zeroext i16 @"cw:UnsignedWordRemainder:func(u16,u16)u16"(i16 noundef zeroext %dividend, i16 noundef zeroext %divisor) {
entry:
  %.result = alloca i16, align 2
  %dividend.addr = alloca i16, align 2
  %divisor.addr = alloca i16, align 2
  store i16 %dividend, ptr %dividend.addr, align 2
  store i16 %divisor, ptr %divisor.addr, align 2
  %0 = load i16, ptr %dividend.addr, align 2
  %1 = load i16, ptr %divisor.addr, align 2
  %rem = urem i16 %0, %1
  store i16 %rem, ptr %.result, align 2
  %2 = load i16, ptr %.result, align 2
  ret i16 %2
}

define noundef i32 @"cw:Unsigned32Quotient:func(u32,u32)u32"(i32 noundef %dividend, i32 noundef %divisor) {
entry:
  %.result = alloca i32, align 4
  %dividend.addr = alloca i32, align 4
  %divisor.addr = alloca i32, align 4
  store i32 %dividend, ptr %dividend.addr, align 4
  store i32 %divisor, ptr %divisor.addr, align 4
  %0 = load i32, ptr %dividend.addr, align 4
  %1 = load i32, ptr %divisor.addr, align 4
  %div = udiv i32 %0, %1
  store i32 %div, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i64 @"cw:UnsignedWideRemainder:func(u64,u64)u64"(i64 noundef %dividend, i64 noundef %divisor) {
entry:
  %.result = alloca i64, align 8
  %dividend.addr = alloca i64, align 8
  %divisor.addr = alloca i64, align 8
  store i64 %dividend, ptr %dividend.addr, align 8
  store i64 %divisor, ptr %divisor.addr, align 8
  %0 = load i64, ptr %dividend.addr, align 8
  %1 = load i64, ptr %divisor.addr, align 8
  %rem = urem i64 %0, %1
  store i64 %rem, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:UnsignedSizeQuotient:func(usize,usize)usize"(i64 noundef %dividend, i64 noundef %divisor) {
entry:
  %.result = alloca i64, align 8
  %dividend.addr = alloca i64, align 8
  %divisor.addr = alloca i64, align 8
  store i64 %dividend, ptr %dividend.addr, align 8
  store i64 %divisor, ptr %divisor.addr, align 8
  %0 = load i64, ptr %dividend.addr, align 8
  %1 = load i64, ptr %divisor.addr, align 8
  %div = udiv i64 %0, %1
  store i64 %div, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:UnsignedMaximumQuotient:func(u64)u64"(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %div = udiv i64 %0, -1
  store i64 %div, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @"cw:UnsignedMaximumRemainder:func(u64)u64"(i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %rem = urem i64 %0, -1
  store i64 %rem, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @"cw:MinimumQuotient:func()i64"() {
entry:
  %.result = alloca i64, align 8
  store i64 -9223372036854775808, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @"cw:MinimumRemainder:func()i64"() {
entry:
  %.result = alloca i64, align 8
  store i64 0, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}
