define noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %value.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8
  %4 = load i32, ptr %3, align 4
  store i32 %4, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define noundef i32 @ReadBeforeCall(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %add = add i32 %1, %call
  store i32 %add, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef zeroext i1 @CompareBeforeCall(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %cmp = icmp eq i32 %1, %call
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %3, 0
  ret i1 %loadedv
}

define noundef i32 @DivideOnce(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8
  %call1 = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = icmp eq i32 %call1, -1
  br i1 %2, label %div.negone, label %div.normal

div.negone:                                       ; preds = %entry
  %sub = sub i32 0, %call
  br label %div.end

div.normal:                                       ; preds = %entry
  %div = sdiv i32 %call, %call1
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div2 = phi i32 [ %sub, %div.negone ], [ %div, %div.normal ]
  store i32 %div2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @RemainderSideEffect(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @ConditionalDivisor(ptr noundef nonnull align 4 dereferenceable(4) %value, i1 noundef zeroext %flag) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  store ptr %value, ptr %value.addr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %1)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load i32, ptr %2, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %call, %cond.true ], [ %3, %cond.false ]
  %4 = load i8, ptr %flag.addr, align 1
  %loadedv4 = icmp ne i8 %4, 0
  br i1 %loadedv4, label %cond.true1, label %cond.false2

cond.true1:                                       ; preds = %cond.end
  br label %cond.end3

cond.false2:                                      ; preds = %cond.end
  %5 = load ptr, ptr %value.addr, align 8
  %call5 = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %5)
  br label %cond.end3

cond.end3:                                        ; preds = %cond.false2, %cond.true1
  %cond6 = phi i32 [ -1, %cond.true1 ], [ %call5, %cond.false2 ]
  %6 = icmp eq i32 %cond6, -1
  br i1 %6, label %div.negone, label %div.normal

div.negone:                                       ; preds = %cond.end3
  %sub = sub i32 0, %cond
  br label %div.end

div.normal:                                       ; preds = %cond.end3
  %div = sdiv i32 %cond, %cond6
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div7 = phi i32 [ %sub, %div.negone ], [ %div, %div.normal ]
  store i32 %div7, ptr %.result, align 4
  %7 = load i32, ptr %.result, align 4
  ret i32 %7
}

define noundef zeroext i1 @ShortCircuitDivision(i1 noundef zeroext %flag, i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %entry
  %1 = load i32, ptr %left.addr, align 4
  %2 = load i32, ptr %right.addr, align 4
  %3 = icmp eq i32 %2, -1
  br i1 %3, label %div.negone, label %div.normal

div.negone:                                       ; preds = %land.rhs
  %sub = sub i32 0, %1
  br label %div.end

div.normal:                                       ; preds = %land.rhs
  %div = sdiv i32 %1, %2
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div1 = phi i32 [ %sub, %div.negone ], [ %div, %div.normal ]
  %cmp = icmp sgt i32 %div1, 0
  br label %land.end

land.end:                                         ; preds = %div.end, %entry
  %4 = phi i1 [ false, %entry ], [ %cmp, %div.end ]
  %storedv2 = zext i1 %4 to i8
  store i8 %storedv2, ptr %.result, align 1
  %5 = load i8, ptr %.result, align 1
  %loadedv3 = icmp ne i8 %5, 0
  ret i1 %loadedv3
}

define noundef i32 @DiscardAndPass(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %add = add i32 %call, 1
  %1 = load ptr, ptr %value.addr, align 8
  %call1 = call noundef i32 @Bump(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %mul = mul i32 %call1, 2
  %call2 = call noundef i32 @Consume(i32 noundef %mul)
  store i32 %call2, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Consume(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}
