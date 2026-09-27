define noundef zeroext i1 @Tick(ptr noundef nonnull align 1 dereferenceable(1) %flag) {
entry:
  %.result = alloca i8, align 1
  %flag.addr = alloca ptr, align 8
  store ptr %flag, ptr %flag.addr, align 8
  %0 = load ptr, ptr %flag.addr, align 8
  %1 = load i8, ptr %0, align 1
  %loadedv = icmp ne i8 %1, 0
  %2 = xor i1 %loadedv, true
  %3 = load ptr, ptr %flag.addr, align 8
  %storedv = zext i1 %2 to i8
  store i8 %storedv, ptr %3, align 1
  %4 = load ptr, ptr %flag.addr, align 8
  %5 = load i8, ptr %4, align 1
  %loadedv1 = icmp ne i8 %5, 0
  %storedv2 = zext i1 %loadedv1 to i8
  store i8 %storedv2, ptr %.result, align 1
  %6 = load i8, ptr %.result, align 1
  %loadedv3 = icmp ne i8 %6, 0
  ret i1 %loadedv3
}

define noundef i32 @WhileLoop(ptr noundef nonnull align 1 dereferenceable(1) %flag, i1 noundef zeroext %skip, i1 noundef zeroext %leave) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca ptr, align 8
  %skip.addr = alloca i8, align 1
  %leave.addr = alloca i8, align 1
  %result = alloca i32, align 4
  store ptr %flag, ptr %flag.addr, align 8
  %storedv = zext i1 %skip to i8
  store i8 %storedv, ptr %skip.addr, align 1
  %storedv1 = zext i1 %leave to i8
  store i8 %storedv1, ptr %leave.addr, align 1
  store i32 0, ptr %result, align 4
  br label %while.cond

while.cond:                                       ; preds = %if.end3, %if.then2, %entry
  %0 = load ptr, ptr %flag.addr, align 8
  %call = call noundef zeroext i1 @Tick(ptr noundef nonnull align 1 dereferenceable(1) %0)
  br i1 %call, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %1 = load i8, ptr %leave.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  br i1 %loadedv, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  br label %while.end

if.end:                                           ; preds = %while.body
  %2 = load i8, ptr %skip.addr, align 1
  %loadedv4 = icmp ne i8 %2, 0
  br i1 %loadedv4, label %if.then2, label %if.end3

if.then2:                                         ; preds = %if.end
  store i8 0, ptr %skip.addr, align 1
  br label %while.cond

if.end3:                                          ; preds = %if.end
  store i32 9, ptr %result, align 4
  br label %while.cond

while.end:                                        ; preds = %if.then, %while.cond
  %3 = load i32, ptr %result, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @NestedLoops(i1 noundef zeroext %outer, i1 noundef zeroext %inner, i1 noundef zeroext %stop, i1 noundef zeroext %finish) {
entry:
  %.result = alloca i32, align 4
  %outer.addr = alloca i8, align 1
  %inner.addr = alloca i8, align 1
  %stop.addr = alloca i8, align 1
  %finish.addr = alloca i8, align 1
  %storedv = zext i1 %outer to i8
  store i8 %storedv, ptr %outer.addr, align 1
  %storedv1 = zext i1 %inner to i8
  store i8 %storedv1, ptr %inner.addr, align 1
  %storedv2 = zext i1 %stop to i8
  store i8 %storedv2, ptr %stop.addr, align 1
  %storedv3 = zext i1 %finish to i8
  store i8 %storedv3, ptr %finish.addr, align 1
  br label %while.cond

while.cond:                                       ; preds = %if.end13, %entry
  %0 = load i8, ptr %outer.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  br label %while.cond4

while.cond4:                                      ; preds = %if.end, %while.body
  %1 = load i8, ptr %inner.addr, align 1
  %loadedv7 = icmp ne i8 %1, 0
  br i1 %loadedv7, label %while.body5, label %while.end6

while.body5:                                      ; preds = %while.cond4
  %2 = load i8, ptr %stop.addr, align 1
  %loadedv8 = icmp ne i8 %2, 0
  br i1 %loadedv8, label %if.then, label %if.end

if.then:                                          ; preds = %while.body5
  br label %while.end6

if.end:                                           ; preds = %while.body5
  store i8 0, ptr %inner.addr, align 1
  br label %while.cond4

while.end6:                                       ; preds = %if.then, %while.cond4
  %3 = load i8, ptr %finish.addr, align 1
  %loadedv11 = icmp ne i8 %3, 0
  br i1 %loadedv11, label %if.then9, label %if.end10

if.then9:                                         ; preds = %while.end6
  store i32 7, ptr %.result, align 4
  br label %return

if.end10:                                         ; preds = %while.end6
  %4 = load i8, ptr %stop.addr, align 1
  %loadedv14 = icmp ne i8 %4, 0
  br i1 %loadedv14, label %if.then12, label %if.end13

if.then12:                                        ; preds = %if.end10
  br label %while.end

if.end13:                                         ; preds = %if.end10
  store i8 0, ptr %outer.addr, align 1
  br label %while.cond

while.end:                                        ; preds = %if.then12, %while.cond
  store i32 9, ptr %.result, align 4
  br label %return

return:                                           ; preds = %while.end, %if.then9
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}
