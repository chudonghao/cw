%struct.Pair = type { i64, i32 }

define noundef ptr @"cw:Forward:func(*i32,usize)*i32"(ptr noundef %pointer, i64 noundef %count) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %add.ptr = getelementptr i32, ptr %0, i64 %1
  store ptr %add.ptr, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Signed:func(isize,*const i32)*const i32"(i64 noundef %count, ptr noundef %pointer) {
entry:
  %.result = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  %pointer.addr = alloca ptr, align 8
  store i64 %count, ptr %count.addr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  %add.ptr = getelementptr i32, ptr %1, i64 %0
  store ptr %add.ptr, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Backward:func(*Pair,usize)*Pair"(ptr noundef %pointer, i64 noundef %count) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %idx.neg = sub i64 0, %1
  %add.ptr = getelementptr %struct.Pair, ptr %0, i64 %idx.neg
  store ptr %add.ptr, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Rows:func(*[3]i16,isize)*[3]i16"(ptr noundef %pointer, i64 noundef %count) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %idx.neg = sub i64 0, %1
  %add.ptr = getelementptr [3 x i16], ptr %0, i64 %idx.neg
  store ptr %add.ptr, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Nested:func(**i32,usize)**i32"(ptr noundef %pointer, i64 noundef %count) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %add.ptr = getelementptr ptr, ptr %0, i64 %1
  store ptr %add.ptr, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Callbacks:func(**func()i32,usize)**func()i32"(ptr noundef %pointer, i64 noundef %count) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %add.ptr = getelementptr ptr, ptr %0, i64 %1
  store ptr %add.ptr, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Interfaces:func(*virtual *func(&copy Pair)i32,isize)*virtual *func(&copy Pair)i32"(ptr noundef %pointer, i64 noundef %count) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %add.ptr = getelementptr { i64, i64 }, ptr %0, i64 %1
  store ptr %add.ptr, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define void @"cw:Advance:func(&mut *i32,usize)void"(ptr noundef nonnull align 8 dereferenceable(8) %pointer, i64 noundef %count) {
entry:
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  %2 = load ptr, ptr %1, align 8
  %add.ptr = getelementptr i32, ptr %2, i64 %0
  store ptr %add.ptr, ptr %1, align 8
  ret void
}

define noundef ptr @"cw:Retreat:func(&mut *Pair,isize)*Pair"(ptr noundef nonnull align 8 dereferenceable(8) %pointer, i64 noundef %count) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  %1 = load ptr, ptr %pointer.addr, align 8
  %2 = load ptr, ptr %1, align 8
  %idx.neg = sub i64 0, %0
  %add.ptr = getelementptr %struct.Pair, ptr %2, i64 %idx.neg
  store ptr %add.ptr, ptr %1, align 8
  %3 = load ptr, ptr %1, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define noundef ptr @"cw:Increment:func(&mut *i32)*i32"(ptr noundef nonnull align 8 dereferenceable(8) %pointer) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load ptr, ptr %0, align 8
  %incdec.ptr = getelementptr i32, ptr %1, i64 1
  store ptr %incdec.ptr, ptr %0, align 8
  %2 = load ptr, ptr %0, align 8
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef ptr @"cw:Decrement:func(&mut *const u8)*const u8"(ptr noundef nonnull align 8 dereferenceable(8) %pointer) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load ptr, ptr %0, align 8
  %incdec.ptr = getelementptr i8, ptr %1, i64 -1
  store ptr %incdec.ptr, ptr %0, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}
