%struct.Item = type { i32 }

define noundef ptr @Item.ctor(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @Item.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Target(ptr noundef %address) {
entry:
  %.result = alloca ptr, align 8
  %address.addr = alloca ptr, align 8
  store ptr %address, ptr %address.addr, align 8
  %0 = load ptr, ptr %address.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @Argument(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef ptr @ConstructAt(ptr noundef %address, i32 noundef %value) {
entry:
  %.result = alloca ptr, align 8
  %address.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %address, ptr %address.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %address.addr, align 8
  %call = call noundef ptr @Target(ptr noundef %0)
  %1 = load i32, ptr %value.addr, align 4
  %call1 = call noundef i32 @Argument(i32 noundef %1)
  %call2 = call noundef ptr @Item.ctor(ptr noundef returned %call, i32 noundef %call1)
  store ptr %call, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define void @DestroyAt(ptr noundef %address) {
entry:
  %address.addr = alloca ptr, align 8
  store ptr %address, ptr %address.addr, align 8
  %0 = load ptr, ptr %address.addr, align 8
  %call = call noundef ptr @Item.dtor(ptr noundef returned %0)
  ret void
}

define void @Manual(ptr noundef %address) {
entry:
  %address.addr = alloca ptr, align 8
  store ptr %address, ptr %address.addr, align 8
  %0 = load ptr, ptr %address.addr, align 8
  %call = call noundef ptr @Target(ptr noundef %0)
  %call1 = call noundef i32 @Argument(i32 noundef 1)
  %call2 = call noundef ptr @Item.ctor(ptr noundef returned %call, i32 noundef %call1)
  %1 = load ptr, ptr %address.addr, align 8
  %call3 = call noundef ptr @Target(ptr noundef %1)
  %call4 = call noundef ptr @Item.dtor(ptr noundef returned %call3)
  ret void
}
