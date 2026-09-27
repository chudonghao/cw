define noundef nonnull align 4 dereferenceable(4) ptr @ForwardMutable(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @ForwardCopy(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @ForwardMove(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @ReplaceThenRead(ptr noundef nonnull align 4 dereferenceable(4) %first, ptr noundef nonnull align 4 dereferenceable(4) %second) {
entry:
  %.result = alloca i32, align 4
  %first.addr = alloca ptr, align 8
  %second.addr = alloca ptr, align 8
  store ptr %first, ptr %first.addr, align 8
  store ptr %second, ptr %second.addr, align 8
  %0 = load ptr, ptr %first.addr, align 8
  store i32 41, ptr %0, align 4
  %1 = load ptr, ptr %second.addr, align 8
  %2 = load i32, ptr %1, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @AliasedArguments() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 1, ptr %value, align 4
  %call = call noundef i32 @ReplaceThenRead(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %value)
  store i32 %call, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
