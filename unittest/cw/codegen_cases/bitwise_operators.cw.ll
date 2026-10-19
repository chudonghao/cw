%"struct.Api::Bits" = type { i32 }

define noundef i32 @"cw:Api::operator~:func(&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %"struct.Api::Bits", ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  %2 = xor i32 %1, -1
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:Api::operator&:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %right.addr, align 8
  %value1 = getelementptr inbounds nuw %"struct.Api::Bits", ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value1, align 4
  %and = and i32 %1, %3
  store i32 %and, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @"cw:Api::operator|:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %right.addr, align 8
  %value1 = getelementptr inbounds nuw %"struct.Api::Bits", ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value1, align 4
  %or = or i32 %1, %3
  store i32 %or, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @"cw:Api::operator^:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %value = getelementptr inbounds nuw %"struct.Api::Bits", ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %right.addr, align 8
  %value1 = getelementptr inbounds nuw %"struct.Api::Bits", ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value1, align 4
  %xor = xor i32 %1, %3
  store i32 %xor, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @"cw:Api::Expressions:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %call = call noundef i32 @"cw:Api::operator~:func(&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load ptr, ptr %right.addr, align 8
  %call1 = call noundef i32 @"cw:Api::operator&:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  %add = add i32 %call, %call1
  %3 = load ptr, ptr %left.addr, align 8
  %4 = load ptr, ptr %right.addr, align 8
  %call2 = call noundef i32 @"cw:Api::operator|:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %3, ptr noundef nonnull align 4 dereferenceable(4) %4)
  %add3 = add i32 %add, %call2
  %5 = load ptr, ptr %left.addr, align 8
  %6 = load ptr, ptr %right.addr, align 8
  %call4 = call noundef i32 @"cw:Api::operator^:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %5, ptr noundef nonnull align 4 dereferenceable(4) %6)
  %add5 = add i32 %add3, %call4
  store i32 %add5, ptr %.result, align 4
  %7 = load i32, ptr %.result, align 4
  ret i32 %7
}

define noundef i32 @"cw:Explicit:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %call = call noundef i32 @"cw:Api::operator~:func(&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load ptr, ptr %right.addr, align 8
  %call1 = call noundef i32 @"cw:Api::operator&:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  %add = add i32 %call, %call1
  %3 = load ptr, ptr %left.addr, align 8
  %4 = load ptr, ptr %right.addr, align 8
  %call2 = call noundef i32 @"cw:Api::operator|:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %3, ptr noundef nonnull align 4 dereferenceable(4) %4)
  %add3 = add i32 %add, %call2
  %5 = load ptr, ptr %left.addr, align 8
  %6 = load ptr, ptr %right.addr, align 8
  %call4 = call noundef i32 @"cw:Api::operator^:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %5, ptr noundef nonnull align 4 dereferenceable(4) %6)
  %add5 = add i32 %add3, %call4
  store i32 %add5, ptr %.result, align 4
  %7 = load i32, ptr %.result, align 4
  ret i32 %7
}

define noundef i32 @"cw:Indirect:func(&copy Api::Bits,&copy Api::Bits)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %invert = alloca ptr, align 8
  %both = alloca ptr, align 8
  %either = alloca ptr, align 8
  %different = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  store ptr @"cw:Api::operator~:func(&copy Api::Bits)i32", ptr %invert, align 8
  store ptr @"cw:Api::operator&:func(&copy Api::Bits,&copy Api::Bits)i32", ptr %both, align 8
  store ptr @"cw:Api::operator|:func(&copy Api::Bits,&copy Api::Bits)i32", ptr %either, align 8
  store ptr @"cw:Api::operator^:func(&copy Api::Bits,&copy Api::Bits)i32", ptr %different, align 8
  %0 = load ptr, ptr %invert, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %call = call noundef i32 %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %both, align 8
  %3 = load ptr, ptr %left.addr, align 8
  %4 = load ptr, ptr %right.addr, align 8
  %call1 = call noundef i32 %2(ptr noundef nonnull align 4 dereferenceable(4) %3, ptr noundef nonnull align 4 dereferenceable(4) %4)
  %add = add i32 %call, %call1
  %5 = load ptr, ptr %either, align 8
  %6 = load ptr, ptr %left.addr, align 8
  %7 = load ptr, ptr %right.addr, align 8
  %call2 = call noundef i32 %5(ptr noundef nonnull align 4 dereferenceable(4) %6, ptr noundef nonnull align 4 dereferenceable(4) %7)
  %add3 = add i32 %add, %call2
  %8 = load ptr, ptr %different, align 8
  %9 = load ptr, ptr %left.addr, align 8
  %10 = load ptr, ptr %right.addr, align 8
  %call4 = call noundef i32 %8(ptr noundef nonnull align 4 dereferenceable(4) %9, ptr noundef nonnull align 4 dereferenceable(4) %10)
  %add5 = add i32 %add3, %call4
  store i32 %add5, ptr %.result, align 4
  %11 = load i32, ptr %.result, align 4
  ret i32 %11
}
