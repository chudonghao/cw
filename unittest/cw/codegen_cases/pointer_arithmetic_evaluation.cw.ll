define noundef i64 @"cw:Count:func(&mut usize)usize"(ptr noundef nonnull align 8 dereferenceable(8) %counter) {
entry:
  %.result = alloca i64, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i64, ptr %0, align 8
  %add = add i64 %1, 1
  store i64 %add, ptr %0, align 8
  %2 = load ptr, ptr %counter.addr, align 8
  %3 = load i64, ptr %2, align 8
  store i64 %3, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef nonnull align 8 dereferenceable(8) ptr @"cw:Locate:func(&mut *i32,&mut usize)&mut *i32"(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %calls) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %calls.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %calls, ptr %calls.addr, align 8
  %0 = load ptr, ptr %calls.addr, align 8
  %1 = load i64, ptr %0, align 8
  %add = add i64 %1, 1
  store i64 %add, ptr %0, align 8
  %2 = load ptr, ptr %pointer.addr, align 8
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef ptr @"cw:OffsetFirst:func(&mut *i32,&mut usize)*i32"(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %counter) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %call = call noundef i64 @"cw:Count:func(&mut usize)usize"(ptr noundef nonnull align 8 dereferenceable(8) %0)
  %1 = load ptr, ptr %pointer.addr, align 8
  %2 = load ptr, ptr %counter.addr, align 8
  %call1 = call noundef nonnull align 8 dereferenceable(8) ptr @"cw:Locate:func(&mut *i32,&mut usize)&mut *i32"(ptr noundef nonnull align 8 dereferenceable(8) %1, ptr noundef nonnull align 8 dereferenceable(8) %2)
  %3 = load ptr, ptr %call1, align 8
  %add.ptr = getelementptr i32, ptr %3, i64 %call
  store ptr %add.ptr, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define noundef ptr @"cw:SourceFirst:func(&mut *i32,&mut usize)*i32"(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %counter) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %call = call noundef i64 @"cw:Count:func(&mut usize)usize"(ptr noundef nonnull align 8 dereferenceable(8) %0)
  %1 = load ptr, ptr %pointer.addr, align 8
  %2 = load ptr, ptr %counter.addr, align 8
  %call1 = call noundef nonnull align 8 dereferenceable(8) ptr @"cw:Locate:func(&mut *i32,&mut usize)&mut *i32"(ptr noundef nonnull align 8 dereferenceable(8) %1, ptr noundef nonnull align 8 dereferenceable(8) %2)
  %3 = load ptr, ptr %call1, align 8
  %add.ptr = getelementptr i32, ptr %3, i64 %call
  store ptr %add.ptr, ptr %call1, align 8
  %4 = load ptr, ptr %call1, align 8
  store ptr %4, ptr %.result, align 8
  %5 = load ptr, ptr %.result, align 8
  ret ptr %5
}

define noundef zeroext i1 @"cw:Old:func(&mut *i32)bool"(ptr noundef nonnull align 8 dereferenceable(8) %pointer) {
entry:
  %.result = alloca i8, align 1
  %pointer.addr = alloca ptr, align 8
  %before = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load ptr, ptr %0, align 8
  %incdec.ptr = getelementptr i32, ptr %1, i64 1
  store ptr %incdec.ptr, ptr %0, align 8
  store ptr %1, ptr %before, align 8
  %2 = load ptr, ptr %before, align 8
  %3 = load ptr, ptr %pointer.addr, align 8
  %4 = load ptr, ptr %3, align 8
  %cmp = icmp ne ptr %2, %4
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %5 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %5, 0
  ret i1 %loadedv
}

define void @"cw:Discard:func(&mut *i32,&mut usize)void"(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %counter) {
entry:
  %pointer.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @"cw:Locate:func(&mut *i32,&mut usize)&mut *i32"(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1)
  %2 = load ptr, ptr %call, align 8
  %incdec.ptr = getelementptr i32, ptr %2, i64 -1
  store ptr %incdec.ptr, ptr %call, align 8
  ret void
}

define noundef i64 @"cw:Distance:func(&mut *i32,&mut usize)isize"(ptr noundef nonnull align 8 dereferenceable(8) %pointer, ptr noundef nonnull align 8 dereferenceable(8) %counter) {
entry:
  %.result = alloca i64, align 8
  %pointer.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @"cw:Locate:func(&mut *i32,&mut usize)&mut *i32"(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1)
  %2 = load ptr, ptr %call, align 8
  %incdec.ptr = getelementptr i32, ptr %2, i64 1
  store ptr %incdec.ptr, ptr %call, align 8
  %3 = load ptr, ptr %pointer.addr, align 8
  %4 = load ptr, ptr %3, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %2 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %4 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = sdiv i64 %sub.ptr.sub, 4
  store i64 %sub.ptr.div, ptr %.result, align 8
  %5 = load i64, ptr %.result, align 8
  ret i64 %5
}
