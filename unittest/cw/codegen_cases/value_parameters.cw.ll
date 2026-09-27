define noundef i32 @Replace(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  store i32 29, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @ValueParameters() {
entry:
  %.result = alloca i32, align 4
  %value = alloca i32, align 4
  store i32 17, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %call = call noundef i32 @Replace(i32 noundef %0)
  %1 = load i32, ptr %value, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}
