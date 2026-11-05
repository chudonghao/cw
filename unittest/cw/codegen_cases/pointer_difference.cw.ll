define noundef i64 @"cw:Elements:func(*i32,*i32)isize"(ptr noundef %last, ptr noundef %first) {
entry:
  %.result = alloca i64, align 8
  %last.addr = alloca ptr, align 8
  %first.addr = alloca ptr, align 8
  store ptr %last, ptr %last.addr, align 8
  store ptr %first, ptr %first.addr, align 8
  %0 = load ptr, ptr %last.addr, align 8
  %1 = load ptr, ptr %first.addr, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %1 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = sdiv i64 %sub.ptr.sub, 4
  store i64 %sub.ptr.div, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:Qualified:func(*const i32,*i32)isize"(ptr noundef %last, ptr noundef %first) {
entry:
  %.result = alloca i64, align 8
  %last.addr = alloca ptr, align 8
  %first.addr = alloca ptr, align 8
  store ptr %last, ptr %last.addr, align 8
  store ptr %first, ptr %first.addr, align 8
  %0 = load ptr, ptr %last.addr, align 8
  %1 = load ptr, ptr %first.addr, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %1 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = sdiv i64 %sub.ptr.sub, 4
  store i64 %sub.ptr.div, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:Bytes:func(*u8,*const u8)isize"(ptr noundef %last, ptr noundef %first) {
entry:
  %.result = alloca i64, align 8
  %last.addr = alloca ptr, align 8
  %first.addr = alloca ptr, align 8
  store ptr %last, ptr %last.addr, align 8
  store ptr %first, ptr %first.addr, align 8
  %0 = load ptr, ptr %last.addr, align 8
  %1 = load ptr, ptr %first.addr, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %1 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  store i64 %sub.ptr.sub, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:Pairs:func(*Pair,*Pair)isize"(ptr noundef %last, ptr noundef %first) {
entry:
  %.result = alloca i64, align 8
  %last.addr = alloca ptr, align 8
  %first.addr = alloca ptr, align 8
  store ptr %last, ptr %last.addr, align 8
  store ptr %first, ptr %first.addr, align 8
  %0 = load ptr, ptr %last.addr, align 8
  %1 = load ptr, ptr %first.addr, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %1 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = sdiv i64 %sub.ptr.sub, 16
  store i64 %sub.ptr.div, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:Rows:func(*[3]i16,*[3]i16)isize"(ptr noundef %last, ptr noundef %first) {
entry:
  %.result = alloca i64, align 8
  %last.addr = alloca ptr, align 8
  %first.addr = alloca ptr, align 8
  store ptr %last, ptr %last.addr, align 8
  store ptr %first, ptr %first.addr, align 8
  %0 = load ptr, ptr %last.addr, align 8
  %1 = load ptr, ptr %first.addr, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %1 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = sdiv i64 %sub.ptr.sub, 6
  store i64 %sub.ptr.div, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:Nested:func(**i32,*const *const i32)isize"(ptr noundef %last, ptr noundef %first) {
entry:
  %.result = alloca i64, align 8
  %last.addr = alloca ptr, align 8
  %first.addr = alloca ptr, align 8
  store ptr %last, ptr %last.addr, align 8
  store ptr %first, ptr %first.addr, align 8
  %0 = load ptr, ptr %last.addr, align 8
  %1 = load ptr, ptr %first.addr, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %1 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = sdiv i64 %sub.ptr.sub, 8
  store i64 %sub.ptr.div, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}
