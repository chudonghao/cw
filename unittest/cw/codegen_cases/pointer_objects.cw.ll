define noundef ptr @Address(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @Read(ptr noundef %pointer) {
entry:
  %.result = alloca i32, align 4
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i32, ptr %0, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define void @Write(ptr noundef %pointer, i32 noundef %value) {
entry:
  %pointer.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %pointer, ptr %pointer.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %1 = load ptr, ptr %pointer.addr, align 8
  store i32 %0, ptr %1, align 4
  ret void
}

define noundef zeroext i1 @Toggle(ptr noundef %pointer) {
entry:
  %.result = alloca i8, align 1
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i8, ptr %0, align 1
  %loadedv = icmp ne i8 %1, 0
  %2 = xor i1 %loadedv, true
  %3 = load ptr, ptr %pointer.addr, align 8
  %storedv = zext i1 %2 to i8
  store i8 %storedv, ptr %3, align 1
  %4 = load ptr, ptr %pointer.addr, align 8
  %5 = load i8, ptr %4, align 1
  %loadedv1 = icmp ne i8 %5, 0
  %storedv2 = zext i1 %loadedv1 to i8
  store i8 %storedv2, ptr %.result, align 1
  %6 = load i8, ptr %.result, align 1
  %loadedv3 = icmp ne i8 %6, 0
  ret i1 %loadedv3
}

define noundef double @Double(ptr noundef %pointer, double noundef %value) {
entry:
  %.result = alloca double, align 8
  %pointer.addr = alloca ptr, align 8
  %value.addr = alloca double, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  store double %0, ptr %1, align 8
  %2 = load ptr, ptr %pointer.addr, align 8
  %3 = load double, ptr %2, align 8
  store double %3, ptr %.result, align 8
  %4 = load double, ptr %.result, align 8
  ret double %4
}

define noundef ptr @Nested(ptr noundef %pointer, ptr noundef %other) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %other.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %other, ptr %other.addr, align 8
  %0 = load ptr, ptr %other.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  store ptr %0, ptr %1, align 8
  %2 = load ptr, ptr %pointer.addr, align 8
  %3 = load ptr, ptr %2, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define noundef i32 @Local() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  %pointer = alloca ptr, align 8
  store i32 7, ptr %value, align 4
  store ptr %value, ptr %pointer, align 8
  %0 = load ptr, ptr %pointer, align 8
  store i32 11, ptr %0, align 4
  %1 = load ptr, ptr %pointer, align 8
  %call = call noundef i32 @Read(ptr noundef %1)
  store i32 %call, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef ptr @Receiver(ptr noundef %pointer) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %call = call noundef ptr @Address(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}
