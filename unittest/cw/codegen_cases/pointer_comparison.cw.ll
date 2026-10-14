define noundef zeroext i1 @"cw:Equal:func(*i32,*const i32)bool"(ptr noundef %left, ptr noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %1 = load ptr, ptr %right.addr, align 8
  %cmp = icmp eq ptr %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NotEqual:func(*const i32,*i32)bool"(ptr noundef %left, ptr noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %1 = load ptr, ptr %right.addr, align 8
  %cmp = icmp ne ptr %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:IsNull:func(*i32)bool"(ptr noundef %pointer) {
entry:
  %.result = alloca i8, align 1
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %cmp = icmp eq ptr %0, null
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %1, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NotNull:func(*i32)bool"(ptr noundef %pointer) {
entry:
  %.result = alloca i8, align 1
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %cmp = icmp ne ptr null, %0
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %1, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:CallbackIsNull:func(*func(i32)i32)bool"(ptr noundef %callback) {
entry:
  %.result = alloca i8, align 1
  %callback.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %cmp = icmp eq ptr %0, null
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %1, 0
  ret i1 %loadedv
}

define noundef ptr @"cw:EmptyCallback:func()*func(i32)i32"() {
entry:
  %.result = alloca ptr, align 8
  store ptr null, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef zeroext i1 @"cw:NullEqual:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 1, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NullUnequal:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 0, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define void @"cw:DiscardNull:func()void"() {
entry:
  ret void
}
