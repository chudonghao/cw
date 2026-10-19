%"struct.Api::Bits" = type { i32 }

define noundef i64 @"cw:Api::operator<<:func(&copy Api::Bits,i64)i64"(ptr noundef nonnull align 4 dereferenceable(4) %left, i64 noundef %count) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load i64, ptr %count.addr, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator>>:func(&mut Api::Bits,i32)&mut Api::Bits"(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %count) {
entry:
  %.result = alloca ptr, align 8
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %count, ptr %count.addr, align 4
  %0 = load ptr, ptr %left.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i64 @"cw:Api::Expressions:func(&mut Api::Bits,i8)i64"(ptr noundef nonnull align 4 dereferenceable(4) %left, i8 noundef signext %count) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  %0 = load ptr, ptr %left.addr, align 8
  %1 = load i8, ptr %count.addr, align 1
  %conv = sext i8 %1 to i32
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator>>:func(&mut Api::Bits,i32)&mut Api::Bits"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %conv)
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %call, i32 0, i32 0
  store i32 7, ptr %value, align 4
  %2 = load ptr, ptr %left.addr, align 8
  %3 = load i8, ptr %count.addr, align 1
  %conv1 = sext i8 %3 to i64
  %call2 = call noundef i64 @"cw:Api::operator<<:func(&copy Api::Bits,i64)i64"(ptr noundef nonnull align 4 dereferenceable(4) %2, i64 noundef %conv1)
  store i64 %call2, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef i64 @"cw:Explicit:func(&mut Api::Bits,i8)i64"(ptr noundef nonnull align 4 dereferenceable(4) %left, i8 noundef signext %count) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  %0 = load ptr, ptr %left.addr, align 8
  %1 = load i8, ptr %count.addr, align 1
  %conv = sext i8 %1 to i32
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator>>:func(&mut Api::Bits,i32)&mut Api::Bits"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %conv)
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %call, i32 0, i32 0
  store i32 7, ptr %value, align 4
  %2 = load ptr, ptr %left.addr, align 8
  %3 = load i8, ptr %count.addr, align 1
  %conv1 = sext i8 %3 to i64
  %call2 = call noundef i64 @"cw:Api::operator<<:func(&copy Api::Bits,i64)i64"(ptr noundef nonnull align 4 dereferenceable(4) %2, i64 noundef %conv1)
  store i64 %call2, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef i64 @"cw:Indirect:func(&mut Api::Bits,i8)i64"(ptr noundef nonnull align 4 dereferenceable(4) %left, i8 noundef signext %count) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %count.addr = alloca i8, align 1
  %shl = alloca ptr, align 8
  %shr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store i8 %count, ptr %count.addr, align 1
  store ptr @"cw:Api::operator<<:func(&copy Api::Bits,i64)i64", ptr %shl, align 8
  store ptr @"cw:Api::operator>>:func(&mut Api::Bits,i32)&mut Api::Bits", ptr %shr, align 8
  %0 = load ptr, ptr %shr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i8, ptr %count.addr, align 1
  %conv = sext i8 %2 to i32
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1, i32 noundef %conv)
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %call, i32 0, i32 0
  store i32 7, ptr %value, align 4
  %3 = load ptr, ptr %shl, align 8
  %4 = load ptr, ptr %left.addr, align 8
  %5 = load i8, ptr %count.addr, align 1
  %conv1 = sext i8 %5 to i64
  %call2 = call noundef i64 %3(ptr noundef nonnull align 4 dereferenceable(4) %4, i64 noundef %conv1)
  store i64 %call2, ptr %.result, align 8
  %6 = load i64, ptr %.result, align 8
  ret i64 %6
}
