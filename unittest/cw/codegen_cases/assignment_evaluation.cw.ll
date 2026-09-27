define noundef nonnull align 4 dereferenceable(4) ptr @MutatingTarget(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store i32 73, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @AssignmentOrder() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 11, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @MutatingTarget(ptr noundef nonnull align 4 dereferenceable(4) %value)
  store i32 %0, ptr %call, align 4
  %1 = load i32, ptr %value, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef nonnull align 4 dereferenceable(4) ptr @Target(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @AssignOnce(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Target(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 17, ptr %call, align 4
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @Change(ptr noundef nonnull align 1 dereferenceable(1) %flag) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca ptr, align 8
  store ptr %flag, ptr %flag.addr, align 8
  %0 = load ptr, ptr %flag.addr, align 8
  %1 = load i8, ptr %0, align 1
  %loadedv = icmp ne i8 %1, 0
  %2 = xor i1 %loadedv, true
  %3 = load ptr, ptr %flag.addr, align 8
  %storedv = zext i1 %2 to i8
  store i8 %storedv, ptr %3, align 1
  store i32 17, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @ConditionalAssignment(i1 noundef zeroext %flag) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca i8, align 1
  %left = alloca i32, align 4
  %right = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 1, ptr %left, align 4
  store i32 2, ptr %right, align 4
  %call = call noundef i32 @Change(ptr noundef nonnull align 1 dereferenceable(1) %flag.addr)
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %left, %cond.true ], [ %right, %cond.false ]
  store i32 %call, ptr %cond, align 4
  %1 = load i8, ptr %flag.addr, align 1
  %loadedv4 = icmp ne i8 %1, 0
  br i1 %loadedv4, label %cond.true1, label %cond.false2

cond.true1:                                       ; preds = %cond.end
  br label %cond.end3

cond.false2:                                      ; preds = %cond.end
  br label %cond.end3

cond.end3:                                        ; preds = %cond.false2, %cond.true1
  %cond5 = phi ptr [ %left, %cond.true1 ], [ %right, %cond.false2 ]
  %2 = load i32, ptr %cond5, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}
