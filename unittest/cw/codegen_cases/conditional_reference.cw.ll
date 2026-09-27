define noundef nonnull align 1 dereferenceable(1) ptr @SelectMutable(i1 noundef zeroext %flag, ptr noundef nonnull align 1 dereferenceable(1) %left, ptr noundef nonnull align 1 dereferenceable(1) %right) {
entry:
  %.result = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %right.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  store ptr %cond, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef zeroext i1 @ReadMutable(i1 noundef zeroext %flag, i1 noundef zeroext %left, i1 noundef zeroext %right) {
entry:
  %.result = alloca i8, align 1
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %left to i8
  store i8 %storedv1, ptr %left.addr, align 1
  %storedv2 = zext i1 %right to i8
  store i8 %storedv2, ptr %right.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef nonnull align 1 dereferenceable(1) ptr @SelectMutable(i1 noundef zeroext %loadedv, ptr noundef nonnull align 1 dereferenceable(1) %left.addr, ptr noundef nonnull align 1 dereferenceable(1) %right.addr)
  %1 = load i8, ptr %call, align 1
  %loadedv3 = icmp ne i8 %1, 0
  %storedv4 = zext i1 %loadedv3 to i8
  store i8 %storedv4, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv5 = icmp ne i8 %2, 0
  ret i1 %loadedv5
}

define noundef nonnull align 1 dereferenceable(1) ptr @SelectCopy(i1 noundef zeroext %flag, ptr noundef nonnull align 1 dereferenceable(1) %left, ptr noundef nonnull align 1 dereferenceable(1) %right) {
entry:
  %.result = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %right.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  store ptr %cond, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef zeroext i1 @ReadCopy(i1 noundef zeroext %flag, i1 noundef zeroext %left, i1 noundef zeroext %right) {
entry:
  %.result = alloca i8, align 1
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %left to i8
  store i8 %storedv1, ptr %left.addr, align 1
  %storedv2 = zext i1 %right to i8
  store i8 %storedv2, ptr %right.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef nonnull align 1 dereferenceable(1) ptr @SelectCopy(i1 noundef zeroext %loadedv, ptr noundef nonnull align 1 dereferenceable(1) %left.addr, ptr noundef nonnull align 1 dereferenceable(1) %right.addr)
  %1 = load i8, ptr %call, align 1
  %loadedv3 = icmp ne i8 %1, 0
  %storedv4 = zext i1 %loadedv3 to i8
  store i8 %storedv4, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv5 = icmp ne i8 %2, 0
  ret i1 %loadedv5
}

define noundef nonnull align 1 dereferenceable(1) ptr @SelectMove(i1 noundef zeroext %flag, ptr noundef nonnull align 1 dereferenceable(1) %left, ptr noundef nonnull align 1 dereferenceable(1) %right) {
entry:
  %.result = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %right.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  store ptr %cond, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef zeroext i1 @ReadMove(i1 noundef zeroext %flag, i1 noundef zeroext %left, i1 noundef zeroext %right) {
entry:
  %.result = alloca i8, align 1
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %left to i8
  store i8 %storedv1, ptr %left.addr, align 1
  %storedv2 = zext i1 %right to i8
  store i8 %storedv2, ptr %right.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef nonnull align 1 dereferenceable(1) ptr @SelectMove(i1 noundef zeroext %loadedv, ptr noundef nonnull align 1 dereferenceable(1) %left.addr, ptr noundef nonnull align 1 dereferenceable(1) %right.addr)
  %1 = load i8, ptr %call, align 1
  %loadedv3 = icmp ne i8 %1, 0
  %storedv4 = zext i1 %loadedv3 to i8
  store i8 %storedv4, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv5 = icmp ne i8 %2, 0
  ret i1 %loadedv5
}
