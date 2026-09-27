%struct.Value = type { i32 }

define noundef ptr @Value.ctor(ptr noundef returned %this, i32 noundef %number) {
entry:
  %number.addr = alloca i32, align 4
  store i32 %number, ptr %number.addr, align 4
  %number1 = getelementptr inbounds nuw %struct.Value, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %number.addr, align 4
  store i32 %0, ptr %number1, align 4
  ret ptr %this
}

define noundef ptr @Value.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"="(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  %2 = load ptr, ptr %target.addr, align 8
  %number1 = getelementptr inbounds nuw %struct.Value, ptr %2, i32 0, i32 0
  store i32 %1, ptr %number1, align 4
  ret void
}

define noundef nonnull align 4 dereferenceable(4) ptr @Target(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %token) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %token.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %token, ptr %token.addr, align 8
  %0 = load ptr, ptr %token.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  %2 = load ptr, ptr %source.addr, align 8
  %number1 = getelementptr inbounds nuw %struct.Value, ptr %2, i32 0, i32 0
  store i32 %1, ptr %number1, align 4
  %3 = load ptr, ptr %target.addr, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define void @Source(ptr sret(%struct.Value) align 4 %.result, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  %call = call noundef ptr @Value.ctor(ptr noundef returned %.result, i32 noundef %1)
  ret void
}

define noundef i32 @Infix() {
entry:
  %.result = alloca i32, align 4
  %source = alloca %struct.Value, align 4
  %target = alloca %struct.Value, align 4
  %temporary = alloca %struct.Value, align 4
  %temporary2 = alloca %struct.Value, align 4
  %call = call noundef ptr @Value.ctor(ptr noundef returned %source, i32 noundef 1)
  %call1 = call noundef ptr @Value.ctor(ptr noundef returned %target, i32 noundef 0)
  call void @Source(ptr sret(%struct.Value) align 4 %temporary, ptr noundef nonnull align 4 dereferenceable(4) %source)
  %call3 = call noundef ptr @Value.ctor(ptr noundef returned %temporary2, i32 noundef 9)
  %call4 = call noundef nonnull align 4 dereferenceable(4) ptr @Target(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %temporary2)
  call void @"="(ptr noundef nonnull align 4 dereferenceable(4) %call4, ptr noundef nonnull align 4 dereferenceable(4) %temporary)
  %call5 = call noundef ptr @Value.dtor(ptr noundef returned %temporary2)
  %call6 = call noundef ptr @Value.dtor(ptr noundef returned %temporary)
  %number = getelementptr inbounds nuw %struct.Value, ptr %target, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  store i32 %0, ptr %.result, align 4
  %call7 = call noundef ptr @Value.dtor(ptr noundef returned %target)
  %call8 = call noundef ptr @Value.dtor(ptr noundef returned %source)
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @Explicit() {
entry:
  %.result = alloca i32, align 4
  %source = alloca %struct.Value, align 4
  %target = alloca %struct.Value, align 4
  %temporary = alloca %struct.Value, align 4
  %temporary4 = alloca %struct.Value, align 4
  %call = call noundef ptr @Value.ctor(ptr noundef returned %source, i32 noundef 1)
  %call1 = call noundef ptr @Value.ctor(ptr noundef returned %target, i32 noundef 0)
  %call2 = call noundef ptr @Value.ctor(ptr noundef returned %temporary, i32 noundef 9)
  %call3 = call noundef nonnull align 4 dereferenceable(4) ptr @Target(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %temporary)
  call void @Source(ptr sret(%struct.Value) align 4 %temporary4, ptr noundef nonnull align 4 dereferenceable(4) %source)
  call void @"="(ptr noundef nonnull align 4 dereferenceable(4) %call3, ptr noundef nonnull align 4 dereferenceable(4) %temporary4)
  %call5 = call noundef ptr @Value.dtor(ptr noundef returned %temporary4)
  %call6 = call noundef ptr @Value.dtor(ptr noundef returned %temporary)
  %number = getelementptr inbounds nuw %struct.Value, ptr %target, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  store i32 %0, ptr %.result, align 4
  %call7 = call noundef ptr @Value.dtor(ptr noundef returned %target)
  %call8 = call noundef ptr @Value.dtor(ptr noundef returned %source)
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}
