define noundef signext i8 @"cw:Signed:func(*func(i8)i8,i8)i8"(ptr noundef %callback, i8 noundef signext %value) {
entry:
  %.result = alloca i8, align 1
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i8, align 1
  store ptr %callback, ptr %callback.addr, align 8
  store i8 %value, ptr %value.addr, align 1
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i8, ptr %value.addr, align 1
  %call = call noundef signext i8 %0(i8 noundef signext %1)
  store i8 %call, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef zeroext i16 @"cw:Unsigned:func(*func(u16)u16,u16)u16"(ptr noundef %callback, i16 noundef zeroext %value) {
entry:
  %.result = alloca i16, align 2
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i16, align 2
  store ptr %callback, ptr %callback.addr, align 8
  store i16 %value, ptr %value.addr, align 2
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i16, ptr %value.addr, align 2
  %call = call noundef zeroext i16 %0(i16 noundef zeroext %1)
  store i16 %call, ptr %.result, align 2
  %2 = load i16, ptr %.result, align 2
  ret i16 %2
}

define noundef zeroext i1 @"cw:Boolean:func(*func(bool)bool,bool)bool"(ptr noundef %callback, i1 noundef zeroext %value) {
entry:
  %.result = alloca i8, align 1
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i8, align 1
  store ptr %callback, ptr %callback.addr, align 8
  %storedv = zext i1 %value to i8
  store i8 %storedv, ptr %value.addr, align 1
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i8, ptr %value.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  %call = call noundef zeroext i1 %0(i1 noundef zeroext %loadedv)
  %storedv1 = zext i1 %call to i8
  store i8 %storedv1, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv2 = icmp ne i8 %2, 0
  ret i1 %loadedv2
}

define noundef double @"cw:Floating:func(*func(f32)f64,i32)f64"(ptr noundef %callback, i32 noundef %value) {
entry:
  %.result = alloca double, align 8
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %callback, ptr %callback.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i32, ptr %value.addr, align 4
  %conv = sitofp i32 %1 to float
  %call = call noundef double %0(float noundef %conv)
  store double %call, ptr %.result, align 8
  %2 = load double, ptr %.result, align 8
  ret double %2
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Reference:func(*func(&mut i32)&mut i32,&mut i32)&mut i32"(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store ptr %call, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @"cw:ReadReference:func(*func(&copy i32)&copy i32,&copy i32)i32"(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load i32, ptr %call, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:MoveReference:func(*func(&move i32)&move i32,&move i32)&move i32"(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store ptr %call, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define void @"cw:Void:func(*func(*i32)void,*i32)void"(ptr noundef %callback, ptr noundef %pointer) {
entry:
  %callback.addr = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  call void %0(ptr noundef %1)
  ret void
}

define noundef i32 @"cw:Chained:func(*func()*func(i32)i32,i32)i32"(ptr noundef %factory, i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %factory.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %factory, ptr %factory.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %factory.addr, align 8
  %call = call noundef ptr %0()
  %1 = load i32, ptr %value.addr, align 4
  %call1 = call noundef i32 %call(i32 noundef %1)
  store i32 %call1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}
