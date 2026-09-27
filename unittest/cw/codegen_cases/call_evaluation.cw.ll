define noundef i32 @Replace(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store i32 67, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8
  %2 = load i32, ptr %1, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @First(i32 noundef %first, i32 noundef %second) {
entry:
  %.result = alloca i32, align 4
  %first.addr = alloca i32, align 4
  %second.addr = alloca i32, align 4
  store i32 %first, ptr %first.addr, align 4
  store i32 %second, ptr %second.addr, align 4
  %0 = load i32, ptr %first.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @OrdinaryCall() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 13, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %call = call noundef i32 @Replace(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call1 = call noundef i32 @First(i32 noundef %0, i32 noundef %call)
  store i32 %call1, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @ReceiverCall() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 13, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %call = call noundef i32 @Replace(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call1 = call noundef i32 @First(i32 noundef %0, i32 noundef %call)
  store i32 %call1, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @ConditionalFirst(i32 noundef %value, i32 noundef %ignored) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  %ignored.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  store i32 %ignored, ptr %ignored.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @ConditionalArgument(i1 noundef zeroext %flag) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca i8, align 1
  %value = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 5, ptr %value, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  store i32 7, ptr %value, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %value, %cond.true ], [ %value, %cond.false ]
  %1 = load i32, ptr %cond, align 4
  store i32 11, ptr %value, align 4
  %2 = load i32, ptr %value, align 4
  %call = call noundef i32 @ConditionalFirst(i32 noundef %1, i32 noundef %2)
  store i32 %call, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef nonnull align 4 dereferenceable(4) ptr @Locate(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store i32 23, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @ReceiverSource() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 13, ptr %value, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Locate(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %0 = load i32, ptr %call, align 4
  %call1 = call noundef i32 @Replace(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call2 = call noundef i32 @First(i32 noundef %0, i32 noundef %call1)
  store i32 %call2, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @ReadFirst(ptr noundef nonnull align 4 dereferenceable(4) %first, i32 noundef %ignored) {
entry:
  %.result = alloca i32, align 4
  %first.addr = alloca ptr, align 8
  %ignored.addr = alloca i32, align 4
  store ptr %first, ptr %first.addr, align 8
  store i32 %ignored, ptr %ignored.addr, align 4
  %0 = load ptr, ptr %first.addr, align 8
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @ReferenceArgument() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 13, ptr %value, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Locate(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call1 = call noundef i32 @Replace(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call2 = call noundef i32 @ReadFirst(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef %call1)
  store i32 %call2, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
