define noundef ptr @Set(ptr noundef nonnull align 8 dereferenceable(8) %target, ptr noundef %next) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %next.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %next, ptr %next.addr, align 8
  %0 = load ptr, ptr %next.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %1, align 8
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load ptr, ptr %2, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define noundef zeroext i1 @CompareBeforeChange(ptr noundef nonnull align 8 dereferenceable(8) %target, ptr noundef %next) {
entry:
  %.result = alloca i8, align 1
  %target.addr = alloca ptr, align 8
  %next.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %next, ptr %next.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8
  %1 = load ptr, ptr %0, align 8
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load ptr, ptr %next.addr, align 8
  %call = call noundef ptr @Set(ptr noundef nonnull align 8 dereferenceable(8) %2, ptr noundef %3)
  %cmp = icmp eq ptr %1, %call
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %4, 0
  ret i1 %loadedv
}

define noundef ptr @Choose(i1 noundef zeroext %flag, ptr noundef %pointer) {
entry:
  %.result = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %pointer.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %pointer.addr, align 8
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ null, %cond.false ]
  store ptr %cond, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 8 dereferenceable(8) ptr @Select(i1 noundef zeroext %flag, ptr noundef nonnull align 8 dereferenceable(8) %left, ptr noundef nonnull align 8 dereferenceable(8) %right) {
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

define void @WriteSelected(i1 noundef zeroext %flag, ptr noundef nonnull align 8 dereferenceable(8) %left, ptr noundef nonnull align 8 dereferenceable(8) %right, ptr noundef %value) {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  %2 = load ptr, ptr %left.addr, align 8
  %3 = load ptr, ptr %right.addr, align 8
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @Select(i1 noundef zeroext %loadedv, ptr noundef nonnull align 8 dereferenceable(8) %2, ptr noundef nonnull align 8 dereferenceable(8) %3)
  store ptr %0, ptr %call, align 8
  ret void
}

define noundef ptr @Locate(ptr noundef %pointer, ptr noundef nonnull align 4 dereferenceable(4) %count) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %count.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %count.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %pointer.addr, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define noundef i32 @Next(ptr noundef nonnull align 4 dereferenceable(4) %value) {
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

define void @AssignOnce(ptr noundef %pointer, ptr noundef nonnull align 4 dereferenceable(4) %state) {
entry:
  %pointer.addr = alloca ptr, align 8
  %state.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %state, ptr %state.addr, align 8
  %0 = load ptr, ptr %state.addr, align 8
  %call = call noundef i32 @Next(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %pointer.addr, align 8
  %2 = load ptr, ptr %state.addr, align 8
  %call1 = call noundef ptr @Locate(ptr noundef %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  store i32 %call, ptr %call1, align 4
  ret void
}
