define noundef i32 @First(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @Other(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %sub = sub i32 0, %0
  store i32 %sub, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @Replace(ptr noundef nonnull align 8 dereferenceable(8) %callback) {
entry:
  %.result = alloca i32, align 4
  %callback.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  store ptr @Other, ptr %0, align 8
  store i32 5, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @Invoke(ptr noundef nonnull align 8 dereferenceable(8) %callback) {
entry:
  %.result = alloca i32, align 4
  %callback.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %0, align 8
  %2 = load ptr, ptr %callback.addr, align 8
  %call = call noundef i32 @Replace(ptr noundef nonnull align 8 dereferenceable(8) %2)
  %call1 = call noundef i32 %1(i32 noundef %call)
  store i32 %call1, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @Run() {
entry:
  %.result = alloca i32, align 4
  %callback = alloca ptr, align 8
  store ptr @First, ptr %callback, align 8
  %call = call noundef i32 @Invoke(ptr noundef nonnull align 8 dereferenceable(8) %callback)
  store i32 %call, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @Mutate(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %value.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8
  %4 = load i32, ptr %3, align 4
  store i32 %4, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define noundef i32 @Arguments(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8
  %2 = load i32, ptr %1, align 4
  %3 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Mutate(ptr noundef nonnull align 4 dereferenceable(4) %3)
  %call1 = call noundef i32 %0(i32 noundef %2, i32 noundef %call)
  store i32 %call1, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}
