define noundef i32 @Bump(ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i8, ptr %0, align 1
  %conv = sext i8 %1 to i32
  %add = add i32 %conv, 1
  %conv1 = trunc i32 %add to i8
  %2 = load ptr, ptr %value.addr, align 8
  store i8 %conv1, ptr %2, align 1
  %3 = load ptr, ptr %value.addr, align 8
  %4 = load i8, ptr %3, align 1
  %conv2 = sext i8 %4 to i32
  store i32 %conv2, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define noundef i32 @ReadBeforeBump(ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i8, ptr %0, align 1
  %conv = sext i8 %1 to i32
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Bump(ptr noundef nonnull align 1 dereferenceable(1) %2)
  %add = add i32 %conv, %call
  store i32 %add, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef nonnull align 2 dereferenceable(2) ptr @Locate(ptr noundef nonnull align 2 dereferenceable(2) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @AssignConverted(ptr noundef nonnull align 2 dereferenceable(2) %value, i64 noundef %source) {
entry:
  %value.addr = alloca ptr, align 8
  %source.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %source, ptr %source.addr, align 8
  %0 = load i64, ptr %source.addr, align 8
  %conv = trunc i64 %0 to i16
  %1 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 2 dereferenceable(2) ptr @Locate(ptr noundef nonnull align 2 dereferenceable(2) %1)
  store i16 %conv, ptr %call, align 2
  ret void
}

define noundef i64 @ReadWide(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %0, align 8
  store i64 %1, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @TemporaryWide() {
entry:
  %.result = alloca i64, align 8
  %temporary = alloca i64, align 8
  store i64 -1, ptr %temporary, align 8
  %call = call noundef i64 @ReadWide(ptr noundef nonnull align 8 dereferenceable(8) %temporary)
  store i64 %call, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef signext i16 @Choose(i1 noundef zeroext %flag, i8 noundef zeroext %left, i16 noundef signext %right) {
entry:
  %.result = alloca i16, align 2
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i16, align 2
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i8 %left, ptr %left.addr, align 1
  store i16 %right, ptr %right.addr, align 2
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i8, ptr %left.addr, align 1
  %conv = zext i8 %1 to i16
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load i16, ptr %right.addr, align 2
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i16 [ %conv, %cond.true ], [ %2, %cond.false ]
  store i16 %cond, ptr %.result, align 2
  %3 = load i16, ptr %.result, align 2
  ret i16 %3
}

define noundef zeroext i16 @IntegerLoop(i8 noundef zeroext %limit) {
entry:
  %.result = alloca i16, align 2
  %limit.addr = alloca i8, align 1
  %index = alloca i8, align 1
  %total = alloca i16, align 2
  %step = alloca i8, align 1
  store i8 %limit, ptr %limit.addr, align 1
  store i8 0, ptr %index, align 1
  store i16 0, ptr %total, align 2
  store i8 1, ptr %step, align 1
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load i8, ptr %index, align 1
  %1 = load i8, ptr %limit.addr, align 1
  %cmp = icmp ult i8 %0, %1
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %2 = load i16, ptr %total, align 2
  %3 = load i8, ptr %index, align 1
  %conv = zext i8 %3 to i16
  %add = add i16 %2, %conv
  store i16 %add, ptr %total, align 2
  %4 = load i8, ptr %index, align 1
  %5 = load i8, ptr %step, align 1
  %add1 = add i8 %4, %5
  store i8 %add1, ptr %index, align 1
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %6 = load i16, ptr %total, align 2
  store i16 %6, ptr %.result, align 2
  %7 = load i16, ptr %.result, align 2
  ret i16 %7
}
