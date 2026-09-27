define noundef nonnull align 4 dereferenceable(4) ptr @Touch(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store i32 47, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @DiscardedExpression() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 1, ptr %value, align 4
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Touch(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %0 = load i32, ptr %value, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}
