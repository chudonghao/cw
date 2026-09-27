define void @Write(ptr noundef nonnull align 4 dereferenceable(4) %target, i32 noundef %value) {
entry:
  %target.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %target, ptr %target.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %1 = load ptr, ptr %target.addr, align 8
  store i32 %0, ptr %1, align 4
  ret void
}

define noundef i32 @ConditionalVoid(i1 noundef zeroext %flag, i1 noundef zeroext %other) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca i8, align 1
  %other.addr = alloca i8, align 1
  %value = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %other to i8
  store i8 %storedv1, ptr %other.addr, align 1
  store i32 0, ptr %value, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  call void @Write(ptr noundef nonnull align 4 dereferenceable(4) %value, i32 noundef 1)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %1 = load i8, ptr %other.addr, align 1
  %loadedv5 = icmp ne i8 %1, 0
  br i1 %loadedv5, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.false
  call void @Write(ptr noundef nonnull align 4 dereferenceable(4) %value, i32 noundef 2)
  br label %cond.end4

cond.false3:                                      ; preds = %cond.false
  call void @Write(ptr noundef nonnull align 4 dereferenceable(4) %value, i32 noundef 3)
  br label %cond.end4

cond.end4:                                        ; preds = %cond.false3, %cond.true2
  br label %cond.end

cond.end:                                         ; preds = %cond.end4, %cond.true
  %2 = load i32, ptr %value, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}
