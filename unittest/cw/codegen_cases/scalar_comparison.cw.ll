define noundef zeroext i1 @Equal(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i32, ptr %right.addr, align 4
  %cmp = icmp eq i32 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @NotEqual(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i32, ptr %right.addr, align 4
  %cmp = icmp ne i32 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @Less(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i32, ptr %right.addr, align 4
  %cmp = icmp slt i32 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @LessEqual(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i32, ptr %right.addr, align 4
  %cmp = icmp sle i32 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @Greater(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i32, ptr %right.addr, align 4
  %cmp = icmp sgt i32 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @GreaterEqual(i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %left.addr, align 4
  %1 = load i32, ptr %right.addr, align 4
  %cmp = icmp sge i32 %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @BooleanEqual(i1 noundef zeroext %left, i1 noundef zeroext %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %storedv = zext i1 %left to i8
  store i8 %storedv, ptr %left.addr, align 1
  %storedv1 = zext i1 %right to i8
  store i8 %storedv1, ptr %right.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %1 = load i8, ptr %right.addr, align 1
  %loadedv2 = icmp ne i8 %1, 0
  %cmp = icmp eq i1 %loadedv, %loadedv2
  %storedv3 = zext i1 %cmp to i8
  store i8 %storedv3, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv4 = icmp ne i8 %2, 0
  ret i1 %loadedv4
}

define noundef zeroext i1 @BooleanNotEqual(i1 noundef zeroext %left, i1 noundef zeroext %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i8, align 1
  %right.addr = alloca i8, align 1
  %storedv = zext i1 %left to i8
  store i8 %storedv, ptr %left.addr, align 1
  %storedv1 = zext i1 %right to i8
  store i8 %storedv1, ptr %right.addr, align 1
  %0 = load i8, ptr %left.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %1 = load i8, ptr %right.addr, align 1
  %loadedv2 = icmp ne i8 %1, 0
  %cmp = icmp ne i1 %loadedv, %loadedv2
  %storedv3 = zext i1 %cmp to i8
  store i8 %storedv3, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv4 = icmp ne i8 %2, 0
  ret i1 %loadedv4
}
