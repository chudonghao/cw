define noundef i32 @ReadInteger(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @IntegerTemporary() {
entry:
  %.result = alloca i32, align 4
  %temporary = alloca i32, align 4
  store i32 53, ptr %temporary, align 4
  %call = call noundef i32 @ReadInteger(ptr noundef nonnull align 4 dereferenceable(4) %temporary)
  store i32 %call, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef zeroext i1 @ReadBoolean(ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i8, ptr %0, align 1
  %loadedv = icmp ne i8 %1, 0
  %storedv = zext i1 %loadedv to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv1 = icmp ne i8 %2, 0
  ret i1 %loadedv1
}

define noundef zeroext i1 @ConditionalBooleanTemporary(i1 noundef zeroext %flag) {
entry:
  %.result = alloca i8, align 1
  %flag.addr = alloca i8, align 1
  %temporary = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i1 [ false, %cond.true ], [ true, %cond.false ]
  %storedv1 = zext i1 %cond to i8
  store i8 %storedv1, ptr %temporary, align 1
  %call = call noundef zeroext i1 @ReadBoolean(ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %storedv2 = zext i1 %call to i8
  store i8 %storedv2, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  %loadedv3 = icmp ne i8 %1, 0
  ret i1 %loadedv3
}
