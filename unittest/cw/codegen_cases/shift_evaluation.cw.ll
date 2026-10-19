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

define noundef i32 @"cw:LeftBeforeCall:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %shift.count = and i32 %call, 31
  %shl = shl i32 %1, %shift.count
  store i32 %shl, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:RightBeforeCall:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %shift.count = and i32 %call, 31
  %ashr = ashr i32 %1, %shift.count
  store i32 %ashr, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
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
  %shift.count = and i32 %call1, 31
  %shl = shl i32 %call, %shift.count
  store i32 %shl, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:ZeroLeft:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %shift.count = and i32 %call, 31
  %shl = shl i32 0, %shift.count
  store i32 %shl, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:ZeroCount:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8
  %call1 = call noundef i32 @"cw:Bump:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %mul = mul i32 %call1, 32
  %shift.count = and i32 %mul, 31
  %ashr = ashr i32 %call, %shift.count
  store i32 %ashr, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}
