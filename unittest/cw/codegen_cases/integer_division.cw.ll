define noundef i32 @Divide(i32 noundef %dividend, i32 noundef %divisor) {
entry:
  %.result = alloca i32, align 4
  %dividend.addr = alloca i32, align 4
  %divisor.addr = alloca i32, align 4
  store i32 %dividend, ptr %dividend.addr, align 4
  store i32 %divisor, ptr %divisor.addr, align 4
  %0 = load i32, ptr %dividend.addr, align 4
  %1 = load i32, ptr %divisor.addr, align 4
  %2 = icmp eq i32 %1, -1
  br i1 %2, label %div.negone, label %div.normal

div.negone:                                       ; preds = %entry
  %sub = sub i32 0, %0
  br label %div.end

div.normal:                                       ; preds = %entry
  %div = sdiv i32 %0, %1
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div1 = phi i32 [ %sub, %div.negone ], [ %div, %div.normal ]
  store i32 %div1, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @Remainder(i32 noundef %dividend, i32 noundef %divisor) {
entry:
  %.result = alloca i32, align 4
  %dividend.addr = alloca i32, align 4
  %divisor.addr = alloca i32, align 4
  store i32 %dividend, ptr %dividend.addr, align 4
  store i32 %divisor, ptr %divisor.addr, align 4
  %0 = load i32, ptr %dividend.addr, align 4
  %1 = load i32, ptr %divisor.addr, align 4
  %2 = icmp eq i32 %1, -1
  br i1 %2, label %rem.negone, label %rem.normal

rem.negone:                                       ; preds = %entry
  br label %rem.end

rem.normal:                                       ; preds = %entry
  %rem = srem i32 %0, %1
  br label %rem.end

rem.end:                                          ; preds = %rem.normal, %rem.negone
  %rem1 = phi i32 [ 0, %rem.negone ], [ %rem, %rem.normal ]
  store i32 %rem1, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @DivideByNegativeOne(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %sub = sub i32 0, %0
  store i32 %sub, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @RemainderByNegativeOne(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @MinimumQuotient() {
entry:
  %.result = alloca i32, align 4
  store i32 -2147483648, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @MinimumRemainder() {
entry:
  %.result = alloca i32, align 4
  store i32 0, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @SignedQuotients() {
entry:
  %.result = alloca i32, align 4
  store i32 -218, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @SignedRemainders() {
entry:
  %.result = alloca i32, align 4
  store i32 -91, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
