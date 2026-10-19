define noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
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

define noundef i32 @"cw:AndBeforeCall:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %and = and i32 %1, %call
  store i32 %and, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:OrBeforeCall:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %or = or i32 %1, %call
  store i32 %or, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:XorBeforeCall:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %xor = xor i32 %1, %call
  store i32 %xor, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:InvertCall:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = xor i32 %call, -1
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:BothCalls:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8
  %call1 = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %and = and i32 %call, %call1
  store i32 %and, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:ZeroMask:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %and = and i32 0, %call
  store i32 %and, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:AllOnesMask:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %or = or i32 -1, %call
  store i32 %or, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}
