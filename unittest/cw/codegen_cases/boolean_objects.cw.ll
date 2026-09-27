define noundef zeroext i1 @Flip(i1 noundef zeroext %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca i8, align 1
  %storedv = zext i1 %value to i8
  store i8 %storedv, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %1 = xor i1 %loadedv, true
  %storedv1 = zext i1 %1 to i8
  store i8 %storedv1, ptr %value.addr, align 1
  %2 = load i8, ptr %value.addr, align 1
  %loadedv2 = icmp ne i8 %2, 0
  %storedv3 = zext i1 %loadedv2 to i8
  store i8 %storedv3, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  %loadedv4 = icmp ne i8 %3, 0
  ret i1 %loadedv4
}

define noundef nonnull align 1 dereferenceable(1) ptr @Refer(ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef zeroext i1 @BooleanObjects() {
entry:
  %.result = alloca i8, align 1
  %original = alloca i8, align 1
  %copied = alloca i8, align 1
  %bound = alloca ptr, align 8
  store i8 1, ptr %original, align 1
  %0 = load i8, ptr %original, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef zeroext i1 @Flip(i1 noundef zeroext %loadedv)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %copied, align 1
  %call1 = call noundef nonnull align 1 dereferenceable(1) ptr @Refer(ptr noundef nonnull align 1 dereferenceable(1) %original)
  store ptr %call1, ptr %bound, align 8
  %1 = load ptr, ptr %bound, align 8
  store i8 0, ptr %1, align 1
  %2 = load i8, ptr %copied, align 1
  %loadedv2 = icmp ne i8 %2, 0
  %storedv3 = zext i1 %loadedv2 to i8
  store i8 %storedv3, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  %loadedv4 = icmp ne i8 %3, 0
  ret i1 %loadedv4
}
