define void @Set(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store i32 43, ptr %0, align 4
  ret void
}

define void @Empty() {
entry:
  ret void
}

define noundef i32 @ExplicitReturn() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 1, ptr %value, align 4
  call void @Set(ptr noundef nonnull align 4 dereferenceable(4) %value)
  call void @Empty()
  %0 = load i32, ptr %value, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @ReturningBranches(i1 noundef zeroext %a, i1 noundef zeroext %b, i1 noundef zeroext %c) {
entry:
  %.result = alloca i32, align 4
  %a.addr = alloca i8, align 1
  %b.addr = alloca i8, align 1
  %c.addr = alloca i8, align 1
  %storedv = zext i1 %a to i8
  store i8 %storedv, ptr %a.addr, align 1
  %storedv1 = zext i1 %b to i8
  store i8 %storedv1, ptr %b.addr, align 1
  %storedv2 = zext i1 %c to i8
  store i8 %storedv2, ptr %c.addr, align 1
  %0 = load i8, ptr %a.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i8, ptr %b.addr, align 1
  %loadedv3 = icmp ne i8 %1, 0
  br i1 %loadedv3, label %if.else, label %if.then

cond.false:                                       ; preds = %entry
  %2 = load i8, ptr %b.addr, align 1
  %loadedv4 = icmp ne i8 %2, 0
  br i1 %loadedv4, label %if.then, label %lor.rhs

lor.rhs:                                          ; preds = %cond.false
  %3 = load i8, ptr %c.addr, align 1
  %loadedv5 = icmp ne i8 %3, 0
  br i1 %loadedv5, label %if.then, label %if.else

if.then:                                          ; preds = %cond.true, %cond.false, %lor.rhs
  store i32 1, ptr %.result, align 4
  br label %return

if.else:                                          ; preds = %cond.true, %lor.rhs
  store i32 2, ptr %.result, align 4
  br label %return

return:                                           ; preds = %if.else, %if.then
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @TailResult(i1 noundef zeroext %flag, i1 noundef zeroext %other) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca i8, align 1
  %other.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %other to i8
  store i8 %storedv1, ptr %other.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 1, ptr %.result, align 4
  br label %if.end3

if.end:                                           ; preds = %entry
  %1 = load i8, ptr %other.addr, align 1
  %loadedv4 = icmp ne i8 %1, 0
  br i1 %loadedv4, label %if.then2, label %if.else

if.then2:                                         ; preds = %if.end
  store i32 2, ptr %.result, align 4
  br label %if.end3

if.else:                                          ; preds = %if.end
  store i32 3, ptr %.result, align 4
  br label %if.end3

if.end3:                                          ; preds = %if.then, %if.else, %if.then2
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define void @SetUnless(i1 noundef zeroext %flag, ptr noundef nonnull align 1 dereferenceable(1) %target) {
entry:
  %flag.addr = alloca i8, align 1
  %target.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %target, ptr %target.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  %1 = load ptr, ptr %target.addr, align 8
  store i8 1, ptr %1, align 1
  br label %return

return:                                           ; preds = %if.end, %if.then
  ret void
}
