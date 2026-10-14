define noundef ptr @"cw:Readonly:func(*i32)*const i32"(ptr noundef %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @"cw:DeepReadonly:func(**i32)*const *const i32"(ptr noundef %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @"cw:ReadReference:func(&copy *i32)*i32"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load ptr, ptr %0, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 8 dereferenceable(8) ptr @"cw:ForwardReference:func(&mut *i32)&mut *i32"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @"cw:Replace:func(&mut *i32,*i32)void"(ptr noundef nonnull align 8 dereferenceable(8) %target, ptr noundef %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %1, align 8
  ret void
}

define noundef zeroext i1 @"cw:Take:func(&copy *i32,&move *i32)bool"(ptr noundef nonnull align 8 dereferenceable(8) %left, ptr noundef nonnull align 8 dereferenceable(8) %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %1 = load ptr, ptr %0, align 8
  %2 = load ptr, ptr %right.addr, align 8
  %3 = load ptr, ptr %2, align 8
  %cmp = icmp eq ptr %1, %3
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %4, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:Temporary:func()bool"() {
entry:
  %.result = alloca i8, align 1
  %temporary = alloca ptr, align 8
  %temporary1 = alloca ptr, align 8
  store ptr null, ptr %temporary, align 8
  store ptr null, ptr %temporary1, align 8
  %call = call noundef zeroext i1 @"cw:Take:func(&copy *i32,&move *i32)bool"(ptr noundef nonnull align 8 dereferenceable(8) %temporary, ptr noundef nonnull align 8 dereferenceable(8) %temporary1)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}
