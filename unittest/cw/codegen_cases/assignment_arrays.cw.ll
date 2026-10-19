%struct.Base = type { i32 }
%struct.Receipt = type { i8 }
%struct.Item = type { %struct.Base }

@"cw:trace:var" = global i64 0, align 8
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @"cw:global_init", ptr null }]

define noundef ptr @"cw:Base:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor(&copy Base):complete"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %value = getelementptr inbounds nuw %struct.Base, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %source.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor(&copy Base):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %value = getelementptr inbounds nuw %struct.Base, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %source.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef %0)
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef %0)
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(&copy Item):complete"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %call = call noundef ptr @"cw:Base:ctor(&copy Base):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %1, 10
  %add = add i64 %mul, 2
  store i64 %add, ptr @"cw:trace:var", align 8
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(&copy Item):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %call = call noundef ptr @"cw:Base:ctor(&copy Base):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %1, 10
  %add = add i64 %mul, 2
  store i64 %add, ptr @"cw:trace:var", align 8
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(&move Item):complete"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %call = call noundef ptr @"cw:Base:ctor(&copy Base):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %1, 10
  %add = add i64 %mul, 3
  store i64 %add, ptr @"cw:trace:var", align 8
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(&move Item):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %call = call noundef ptr @"cw:Base:ctor(&copy Base):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %1, 10
  %add = add i64 %mul, 3
  store i64 %add, ptr @"cw:trace:var", align 8
  ret ptr %this
}

define noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %this) {
entry:
  %0 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %0, 10
  %add = add i64 %mul, 4
  store i64 %add, ptr @"cw:trace:var", align 8
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Item:dtor():base"(ptr noundef returned %this) {
entry:
  %0 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %0, 10
  %add = add i64 %mul, 4
  store i64 %add, ptr @"cw:trace:var", align 8
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Receipt:ctor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Receipt:ctor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Receipt:dtor():complete"(ptr noundef returned %this) {
entry:
  %0 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %0, 10
  %add = add i64 %mul, 6
  store i64 %add, ptr @"cw:trace:var", align 8
  ret ptr %this
}

define noundef ptr @"cw:Receipt:dtor():base"(ptr noundef returned %this) {
entry:
  %0 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %0, 10
  %add = add i64 %mul, 6
  store i64 %add, ptr @"cw:trace:var", align 8
  ret ptr %this
}

define void @"cw:operator=:func(&mut Base,Item)Receipt"(ptr sret(%struct.Receipt) align 1 %.result, ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef %source) {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %value = getelementptr inbounds nuw %struct.Base, ptr %source, i32 0, i32 0
  %0 = load i32, ptr %value, align 4
  %1 = load ptr, ptr %target.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %1, i32 0, i32 0
  store i32 %0, ptr %value1, align 4
  %2 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %2, 10
  %add = add i64 %mul, 5
  store i64 %add, ptr @"cw:trace:var", align 8
  %call = call noundef ptr @"cw:Receipt:ctor():complete"(ptr noundef returned %.result)
  ret void
}

define void @"cw:Copy:func(&mut [2]Item,&copy [2]Item)void"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %temporary = alloca %struct.Receipt, align 1
  %argument = alloca %struct.Item, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.assign, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.assign ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Item], ptr %0, i64 0, i64 %array.index
  %call = call noundef ptr @"cw:Item:ctor(&copy Item):complete"(ptr noundef returned %argument, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  call void @"cw:operator=:func(&mut Base,Item)Receipt"(ptr sret(%struct.Receipt) align 1 %temporary, ptr noundef nonnull align 4 dereferenceable(4) %element, ptr noundef %argument)
  %call2 = call noundef ptr @"cw:Receipt:dtor():complete"(ptr noundef returned %temporary)
  %call3 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %argument)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  ret void
}

define void @"cw:Move:func(&mut [2]Item,&move [2]Item)void"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %temporary = alloca %struct.Receipt, align 1
  %argument = alloca %struct.Item, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.assign, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.assign ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Item], ptr %0, i64 0, i64 %array.index
  %call = call noundef ptr @"cw:Item:ctor(&move Item):complete"(ptr noundef returned %argument, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  call void @"cw:operator=:func(&mut Base,Item)Receipt"(ptr sret(%struct.Receipt) align 1 %temporary, ptr noundef nonnull align 4 dereferenceable(4) %element, ptr noundef %argument)
  %call2 = call noundef ptr @"cw:Receipt:dtor():complete"(ptr noundef returned %temporary)
  %call3 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %argument)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  ret void
}

define void @"cw:Nested:func(&mut [1][2]Item,&copy [1][2]Item)void"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %temporary = alloca %struct.Receipt, align 1
  %argument = alloca %struct.Item, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.end3, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next9, %array.end3 ]
  %element = getelementptr inbounds nuw [1 x [2 x %struct.Item]], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [1 x [2 x %struct.Item]], ptr %0, i64 0, i64 %array.index
  br label %array.assign2

array.assign2:                                    ; preds = %array.assign2, %array.assign
  %array.index4 = phi i64 [ 0, %array.assign ], [ %array.next, %array.assign2 ]
  %element5 = getelementptr inbounds nuw [2 x %struct.Item], ptr %element, i64 0, i64 %array.index4
  %element6 = getelementptr inbounds nuw [2 x %struct.Item], ptr %element1, i64 0, i64 %array.index4
  %call = call noundef ptr @"cw:Item:ctor(&copy Item):complete"(ptr noundef returned %argument, ptr noundef nonnull align 4 dereferenceable(4) %element6)
  call void @"cw:operator=:func(&mut Base,Item)Receipt"(ptr sret(%struct.Receipt) align 1 %temporary, ptr noundef nonnull align 4 dereferenceable(4) %element5, ptr noundef %argument)
  %call7 = call noundef ptr @"cw:Receipt:dtor():complete"(ptr noundef returned %temporary)
  %call8 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %argument)
  %array.next = add i64 %array.index4, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end3, label %array.assign2

array.end3:                                       ; preds = %array.assign2
  %array.next9 = add i64 %array.index, 1
  %array.finished10 = icmp eq i64 %array.next9, 1
  br i1 %array.finished10, label %array.end, label %array.assign

array.end:                                        ; preds = %array.end3
  ret void
}

define void @"cw:Zero:func(&mut [0]Item,&copy [0]Item)void"(ptr noundef nonnull align 4 %target, ptr noundef nonnull align 4 %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  ret void
}

define noundef i32 @"cw:ByValue::operator=:func(Item,&copy Base)i32"(ptr noundef %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i32, align 4
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %value = getelementptr inbounds nuw %struct.Base, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %target, i32 0, i32 0
  store i32 %1, ptr %value1, align 4
  store i32 7, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define void @"cw:ByValue::Copy:func(&mut [2]Item,&copy [2]Item)void"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %argument = alloca %struct.Item, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.assign, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.assign ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Item], ptr %0, i64 0, i64 %array.index
  %call = call noundef ptr @"cw:Item:ctor(&copy Item):complete"(ptr noundef returned %argument, ptr noundef nonnull align 4 dereferenceable(4) %element)
  %call2 = call noundef i32 @"cw:ByValue::operator=:func(Item,&copy Base)i32"(ptr noundef %argument, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %call3 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %argument)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  ret void
}

define internal void @"cw:global_var_init"() {
entry:
  store i64 0, ptr @"cw:trace:var", align 8
  ret void
}

define internal void @"cw:global_init"() {
entry:
  call void @"cw:global_var_init"()
  ret void
}
