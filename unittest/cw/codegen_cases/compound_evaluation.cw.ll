%struct.Item = type { i32 }

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Locate:func(&mut i32,&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Change:func(&mut i32,&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  store i32 9, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @"cw:Capture:func(&mut i32,&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load ptr, ptr %source.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Change:func(&mut i32,&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  %4 = load i32, ptr %call, align 4
  %add = add i32 %4, %1
  store i32 %add, ptr %call, align 4
  %5 = load i32, ptr %call, align 4
  store i32 %5, ptr %.result, align 4
  %6 = load i32, ptr %.result, align 4
  ret i32 %6
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Once:func(&mut i32,&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store i32 2, ptr %0, align 4
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Locate:func(&mut i32,&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  %4 = load i32, ptr %call, align 4
  %add = add i32 %4, %1
  store i32 %add, ptr %call, align 4
  store ptr %call, ptr %.result, align 8
  %5 = load ptr, ptr %.result, align 8
  ret ptr %5
}

define noundef i32 @"cw:ReadAfterRight:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store i32 2, ptr %0, align 4
  %1 = load i32, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load i32, ptr %2, align 4
  %add = add i32 %3, %1
  store i32 %add, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  store i32 %4, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Chain:func(&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 2
  store i32 %add, ptr %0, align 4
  %2 = load i32, ptr %0, align 4
  %mul = mul i32 %2, 3
  store i32 %mul, ptr %0, align 4
  store ptr %0, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef i32 @"cw:RightAssociated:func(&mut i32,&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %right.addr, align 8
  %1 = load i32, ptr %0, align 4
  %mul = mul i32 %1, 2
  store i32 %mul, ptr %0, align 4
  %2 = load i32, ptr %0, align 4
  %3 = load ptr, ptr %left.addr, align 8
  %4 = load i32, ptr %3, align 4
  %add = add i32 %4, %2
  store i32 %add, ptr %3, align 4
  %5 = load i32, ptr %3, align 4
  store i32 %5, ptr %.result, align 4
  %6 = load i32, ptr %.result, align 4
  ret i32 %6
}

define noundef ptr @"cw:Address:func(&mut i32)*i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 2
  store i32 %add, ptr %0, align 4
  store ptr %0, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @"cw:Field:func(&mut Item)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  %add = add i32 %1, 3
  store i32 %add, ptr %value1, align 4
  %2 = load i32, ptr %value1, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:Element:func(&mut [2]i32,usize)i32"(ptr noundef nonnull align 4 dereferenceable(8) %value, i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %index.addr, align 8
  %element = getelementptr [2 x i32], ptr %0, i64 0, i64 %1
  store i32 2, ptr %element, align 4
  %2 = load i32, ptr %element, align 4
  %3 = load ptr, ptr %value.addr, align 8
  %4 = load i64, ptr %index.addr, align 8
  %element1 = getelementptr [2 x i32], ptr %3, i64 0, i64 %4
  %5 = load i32, ptr %element1, align 4
  %add = add i32 %5, %2
  store i32 %add, ptr %element1, align 4
  %6 = load i32, ptr %element1, align 4
  store i32 %6, ptr %.result, align 4
  %7 = load i32, ptr %.result, align 4
  ret i32 %7
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Conditional:func(&mut i32,&mut i32,bool)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %first, ptr noundef nonnull align 4 dereferenceable(4) %second, i1 noundef zeroext %choose) {
entry:
  %.result = alloca ptr, align 8
  %first.addr = alloca ptr, align 8
  %second.addr = alloca ptr, align 8
  %choose.addr = alloca i8, align 1
  store ptr %first, ptr %first.addr, align 8
  store ptr %second, ptr %second.addr, align 8
  %storedv = zext i1 %choose to i8
  store i8 %storedv, ptr %choose.addr, align 1
  %0 = load i8, ptr %choose.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %first.addr, align 8
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %second.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  %3 = load i32, ptr %cond, align 4
  %add = add i32 %3, 3
  store i32 %add, ptr %cond, align 4
  store ptr %cond, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define void @"cw:Discard:func(&mut i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 2
  store i32 %add, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load i32, ptr %2, align 4
  %shl = shl i32 %3, 0
  store i32 %shl, ptr %2, align 4
  ret void
}
