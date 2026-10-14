%struct.Item = type { i32 }

define noundef ptr @"cw:Item:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Item:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"cw:Inspect:func(&copy Item)void"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  ret void
}

define void @"cw:Make:func()Item"(ptr sret(%struct.Item) align 4 %.result) {
entry:
  %call = call noundef ptr @"cw:Item:ctor(i32):complete"(ptr noundef returned %.result, i32 noundef 1)
  ret void
}

define void @"cw:Named:func()Item"(ptr sret(%struct.Item) align 4 %result) {
entry:
  %call = call noundef ptr @"cw:Item:ctor(i32):complete"(ptr noundef returned %result, i32 noundef 2)
  call void @"cw:Inspect:func(&copy Item)void"(ptr noundef nonnull align 4 dereferenceable(4) %result)
  ret void
}

define void @"cw:Select:func(bool)Item"(ptr sret(%struct.Item) align 4 %.result, i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  call void @"cw:Make:func()Item"(ptr sret(%struct.Item) align 4 %.result)
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @"cw:Named:func()Item"(ptr sret(%struct.Item) align 4 %.result)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  ret void
}

define void @"cw:Results:func()void"() {
entry:
  %value = alloca %struct.Item, align 4
  %temporary = alloca %struct.Item, align 4
  call void @"cw:Make:func()Item"(ptr sret(%struct.Item) align 4 %value)
  call void @"cw:Inspect:func(&copy Item)void"(ptr noundef nonnull align 4 dereferenceable(4) %value)
  call void @"cw:Named:func()Item"(ptr sret(%struct.Item) align 4 %temporary)
  %call = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %temporary)
  %call1 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %value)
  ret void
}
