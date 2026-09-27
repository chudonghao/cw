define noundef i32 @Select(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store i32 7, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @Select.1(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store i32 13, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @Select.2(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store i32 19, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @FunctionOverloading() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  %fixed = alloca i32, align 4
  store i32 0, ptr %value, align 4
  store i32 0, ptr %fixed, align 4
  %call = call noundef i32 @Select.1(ptr noundef nonnull align 4 dereferenceable(4) %value)
  %call1 = call noundef i32 @Select(ptr noundef nonnull align 4 dereferenceable(4) %fixed)
  %call2 = call noundef i32 @Select.2(ptr noundef nonnull align 4 dereferenceable(4) %value)
  store i32 %call2, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
