%struct.Number = type { i32 }

define noundef i32 @-(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  %sub = sub i32 0, %1
  store i32 %sub, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @-.1(ptr noundef nonnull align 4 dereferenceable(4) %left, i16 noundef signext %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i16, align 2
  store ptr %left, ptr %left.addr, align 8
  store i16 %right, ptr %right.addr, align 2
  %0 = load ptr, ptr %left.addr, align 8
  %value = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load i16, ptr %right.addr, align 2
  %conv = sext i16 %2 to i32
  %sub = sub i32 %1, %conv
  store i32 %sub, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @Unary(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @-(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @Binary(ptr noundef nonnull align 4 dereferenceable(4) %value, i8 noundef signext %amount) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %amount.addr = alloca i8, align 1
  store ptr %value, ptr %value.addr, align 8
  store i8 %amount, ptr %amount.addr, align 1
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i8, ptr %amount.addr, align 1
  %conv = sext i8 %1 to i16
  %call = call noundef i32 @-.1(ptr noundef nonnull align 4 dereferenceable(4) %0, i16 noundef signext %conv)
  store i32 %call, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Explicit(ptr noundef nonnull align 4 dereferenceable(4) %value, i16 noundef signext %amount) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %amount.addr = alloca i16, align 2
  store ptr %value, ptr %value.addr, align 8
  store i16 %amount, ptr %amount.addr, align 2
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i16, ptr %amount.addr, align 2
  %call = call noundef i32 @-.1(ptr noundef nonnull align 4 dereferenceable(4) %0, i16 noundef signext %1)
  store i32 %call, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Indirect(ptr noundef nonnull align 4 dereferenceable(4) %value, i16 noundef signext %amount) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %amount.addr = alloca i16, align 2
  %operation = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store i16 %amount, ptr %amount.addr, align 2
  store ptr @-.1, ptr %operation, align 8
  %0 = load ptr, ptr %operation, align 8
  %1 = load ptr, ptr %value.addr, align 8
  %2 = load i16, ptr %amount.addr, align 2
  %call = call noundef i32 %0(ptr noundef nonnull align 4 dereferenceable(4) %1, i16 noundef signext %2)
  store i32 %call, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}
