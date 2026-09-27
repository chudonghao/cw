define noundef zeroext i1 @Touch(ptr noundef nonnull align 1 dereferenceable(1) %flag) {
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

define noundef zeroext i1 @BooleanLogic(i1 noundef zeroext %a, i1 noundef zeroext %b, i1 noundef zeroext %c, ptr noundef nonnull align 1 dereferenceable(1) %flag) {
entry:
  %.result = alloca i8, align 1
  %a.addr = alloca i8, align 1
  %b.addr = alloca i8, align 1
  %c.addr = alloca i8, align 1
  %flag.addr = alloca ptr, align 8
  %storedv = zext i1 %a to i8
  store i8 %storedv, ptr %a.addr, align 1
  %storedv1 = zext i1 %b to i8
  store i8 %storedv1, ptr %b.addr, align 1
  %storedv2 = zext i1 %c to i8
  store i8 %storedv2, ptr %c.addr, align 1
  store ptr %flag, ptr %flag.addr, align 8
  %0 = load i8, ptr %a.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %land.rhs3, label %land.end

land.rhs3:                                        ; preds = %entry
  %1 = load i8, ptr %b.addr, align 1
  %loadedv4 = icmp ne i8 %1, 0
  br i1 %loadedv4, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %land.rhs3
  %2 = load i8, ptr %c.addr, align 1
  %loadedv5 = icmp ne i8 %2, 0
  br i1 %loadedv5, label %lor.end, label %lor.rhs

lor.rhs:                                          ; preds = %land.rhs
  %3 = load ptr, ptr %flag.addr, align 8
  %call = call noundef zeroext i1 @Touch(ptr noundef nonnull align 1 dereferenceable(1) %3)
  br label %lor.end

lor.end:                                          ; preds = %lor.rhs, %land.rhs
  %4 = phi i1 [ true, %land.rhs ], [ %call, %lor.rhs ]
  br label %land.end

land.end:                                         ; preds = %lor.end, %land.rhs3, %entry
  %5 = phi i1 [ false, %land.rhs3 ], [ false, %entry ], [ %4, %lor.end ]
  %storedv6 = zext i1 %5 to i8
  store i8 %storedv6, ptr %.result, align 1
  %6 = load i8, ptr %.result, align 1
  %loadedv7 = icmp ne i8 %6, 0
  ret i1 %loadedv7
}
