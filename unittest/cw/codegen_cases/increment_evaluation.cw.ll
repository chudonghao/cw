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

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Prefix:func(&mut i32,&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Locate:func(&mut i32,&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load i32, ptr %call, align 4
  %add = add i32 %2, 1
  store i32 %add, ptr %call, align 4
  store ptr %call, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef i32 @"cw:Postfix:func(&mut i32,&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Locate:func(&mut i32,&mut i32)&mut i32"(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load i32, ptr %call, align 4
  %sub = sub i32 %2, 1
  store i32 %sub, ptr %call, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:Pair:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load i32, ptr %2, align 4
  %add1 = add i32 %1, %3
  store i32 %add1, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @"cw:Mixed:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load i32, ptr %0, align 4
  %3 = load ptr, ptr %value.addr, align 8
  %4 = load i32, ptr %3, align 4
  %add1 = add i32 %4, 1
  store i32 %add1, ptr %3, align 4
  %add2 = add i32 %2, %4
  store i32 %add2, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define noundef i32 @"cw:SelfAssignment:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  store i32 %1, ptr %2, align 4
  %3 = load i32, ptr %2, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @"cw:Element:func(&mut [2]i32,&mut usize)i32"(ptr noundef nonnull align 4 dereferenceable(8) %data, ptr noundef nonnull align 8 dereferenceable(8) %index) {
entry:
  %.result = alloca i32, align 4
  %data.addr = alloca ptr, align 8
  %index.addr = alloca ptr, align 8
  store ptr %data, ptr %data.addr, align 8
  store ptr %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %data.addr, align 8
  %1 = load ptr, ptr %index.addr, align 8
  %2 = load i64, ptr %1, align 8
  %add = add i64 %2, 1
  store i64 %add, ptr %1, align 8
  %element = getelementptr [2 x i32], ptr %0, i64 0, i64 %2
  %3 = load i32, ptr %element, align 4
  %add1 = add i32 %3, 1
  store i32 %add1, ptr %element, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @"cw:Conditional:func(&mut i32,&mut i32,bool)i32"(ptr noundef nonnull align 4 dereferenceable(4) %first, ptr noundef nonnull align 4 dereferenceable(4) %second, i1 noundef zeroext %choose) {
entry:
  %.result = alloca i32, align 4
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
  %add = add i32 %3, 1
  store i32 %add, ptr %cond, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef zeroext i1 @"cw:ShortCircuit:func(&mut i32,bool)bool"(ptr noundef nonnull align 4 dereferenceable(4) %value, i1 noundef zeroext %choose) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  %choose.addr = alloca i8, align 1
  store ptr %value, ptr %value.addr, align 8
  %storedv = zext i1 %choose to i8
  store i8 %storedv, ptr %choose.addr, align 1
  %0 = load i8, ptr %choose.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %entry
  %1 = load ptr, ptr %value.addr, align 8
  %2 = load i32, ptr %1, align 4
  %add = add i32 %2, 1
  store i32 %add, ptr %1, align 4
  %cmp = icmp eq i32 %2, 1
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %3 = phi i1 [ false, %entry ], [ %cmp, %land.rhs ]
  %storedv1 = zext i1 %3 to i8
  store i8 %storedv1, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  %loadedv2 = icmp ne i8 %4, 0
  ret i1 %loadedv2
}

define noundef ptr @"cw:Address:func(&mut i32)*i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %sub = sub i32 %1, 1
  store i32 %sub, ptr %0, align 4
  store ptr %0, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @"cw:Chain:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load i32, ptr %0, align 4
  %add1 = add i32 %2, 1
  store i32 %add1, ptr %0, align 4
  %3 = load i32, ptr %0, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define void @"cw:Assign:func(&mut i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  store i32 5, ptr %0, align 4
  ret void
}

define noundef i32 @"cw:Compound:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load i32, ptr %2, align 4
  %add1 = add i32 %3, 1
  store i32 %add1, ptr %2, align 4
  %4 = load i32, ptr %2, align 4
  %add2 = add i32 %4, %1
  store i32 %add2, ptr %2, align 4
  %5 = load i32, ptr %2, align 4
  store i32 %5, ptr %.result, align 4
  %6 = load i32, ptr %.result, align 4
  ret i32 %6
}

define noundef i32 @"cw:Field:func(&mut Item)i32"(ptr noundef nonnull align 4 dereferenceable(4) %item) {
entry:
  %.result = alloca i32, align 4
  %item.addr = alloca ptr, align 8
  store ptr %item, ptr %item.addr, align 8
  %0 = load ptr, ptr %item.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %value, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:Dereference:func(*i32)i32"(ptr noundef %pointer) {
entry:
  %.result = alloca i32, align 4
  %pointer.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  %1 = load i32, ptr %0, align 4
  %sub = sub i32 %1, 1
  store i32 %sub, ptr %0, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define void @"cw:Discard:func(&mut i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load i32, ptr %2, align 4
  %add1 = add i32 %3, 1
  store i32 %add1, ptr %2, align 4
  %4 = load ptr, ptr %value.addr, align 8
  %5 = load i32, ptr %4, align 4
  %sub = sub i32 %5, 1
  store i32 %sub, ptr %4, align 4
  %6 = load ptr, ptr %value.addr, align 8
  %7 = load i32, ptr %6, align 4
  %sub2 = sub i32 %7, 1
  store i32 %sub2, ptr %6, align 4
  ret void
}
