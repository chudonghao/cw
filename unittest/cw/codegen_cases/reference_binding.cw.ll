define noundef nonnull align 4 dereferenceable(4) ptr @Forward(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @ReferenceBinding() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  %link = alloca ptr, align 8
  store i32 3, ptr %value, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Forward(ptr noundef nonnull align 4 dereferenceable(4) %value)
  store ptr %call, ptr %link, align 8
  %0 = load ptr, ptr %link, align 8
  store i32 19, ptr %0, align 4
  %1 = load i32, ptr %value, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}
