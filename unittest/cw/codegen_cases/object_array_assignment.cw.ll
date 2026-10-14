%struct.Item = type { i32 }
%struct.CopyOnly = type { i32 }
%struct.Empty = type { i8 }

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

define void @"cw:operator=:func(&mut Item,&copy Item)void"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %target.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %2, i32 0, i32 0
  store i32 %1, ptr %value1, align 4
  ret void
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:operator=:func(&mut Item,&move Item)&mut Item"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %target.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %2, i32 0, i32 0
  store i32 %1, ptr %value1, align 4
  %3 = load ptr, ptr %target.addr, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define noundef nonnull align 4 dereferenceable(8) ptr @"cw:Copy:func(&mut [2]Item,&copy [2]Item)&mut [2]Item"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.assign, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.assign ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Item], ptr %0, i64 0, i64 %array.index
  call void @"cw:operator=:func(&mut Item,&copy Item)void"(ptr noundef nonnull align 4 dereferenceable(4) %element, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 4 dereferenceable(8) ptr @"cw:Move:func(&mut [2]Item,&move [2]Item)&mut [2]Item"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.assign, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.assign ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Item], ptr %0, i64 0, i64 %array.index
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:operator=:func(&mut Item,&move Item)&mut Item"(ptr noundef nonnull align 4 dereferenceable(4) %element, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define void @"cw:Nested:func(&mut [2][2]Item,&copy [2][2]Item)void"(ptr noundef nonnull align 4 dereferenceable(16) %target, ptr noundef nonnull align 4 dereferenceable(16) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.end3, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next7, %array.end3 ]
  %element = getelementptr inbounds nuw [2 x [2 x %struct.Item]], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x [2 x %struct.Item]], ptr %0, i64 0, i64 %array.index
  br label %array.assign2

array.assign2:                                    ; preds = %array.assign2, %array.assign
  %array.index4 = phi i64 [ 0, %array.assign ], [ %array.next, %array.assign2 ]
  %element5 = getelementptr inbounds nuw [2 x %struct.Item], ptr %element, i64 0, i64 %array.index4
  %element6 = getelementptr inbounds nuw [2 x %struct.Item], ptr %element1, i64 0, i64 %array.index4
  call void @"cw:operator=:func(&mut Item,&copy Item)void"(ptr noundef nonnull align 4 dereferenceable(4) %element5, ptr noundef nonnull align 4 dereferenceable(4) %element6)
  %array.next = add i64 %array.index4, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end3, label %array.assign2

array.end3:                                       ; preds = %array.assign2
  %array.next7 = add i64 %array.index, 1
  %array.finished8 = icmp eq i64 %array.next7, 2
  br i1 %array.finished8, label %array.end, label %array.assign

array.end:                                        ; preds = %array.end3
  ret void
}

define noundef ptr @"cw:CopyOnly:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.CopyOnly, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:CopyOnly:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.CopyOnly, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:CopyOnly:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:CopyOnly:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef i32 @"cw:operator=:func(&mut CopyOnly,&copy CopyOnly)i32"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i32, align 4
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %value = getelementptr inbounds nuw %struct.CopyOnly, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %target.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.CopyOnly, ptr %2, i32 0, i32 0
  store i32 %1, ptr %value1, align 4
  store i32 7, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define void @"cw:Fallback:func(&mut [2]CopyOnly,&move [2]CopyOnly)void"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.assign, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.assign ]
  %element = getelementptr inbounds nuw [2 x %struct.CopyOnly], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.CopyOnly], ptr %0, i64 0, i64 %array.index
  %call = call noundef i32 @"cw:operator=:func(&mut CopyOnly,&copy CopyOnly)i32"(ptr noundef nonnull align 4 dereferenceable(4) %element, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  ret void
}

define noundef nonnull align 4 ptr @"cw:ZeroSource:func(&copy [3][0]Item,&mut i32)&copy [3][0]Item"(ptr noundef nonnull align 4 %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %mul = mul i32 %1, 10
  %add = add i32 %mul, 1
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %source.addr, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define noundef nonnull align 4 ptr @"cw:ZeroTarget:func(&mut [3][0]Item,&mut i32)&mut [3][0]Item"(ptr noundef nonnull align 4 %target, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %mul = mul i32 %1, 10
  %add = add i32 %mul, 2
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %target.addr, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define void @"cw:NestedZero:func(&mut [3][0]Item,&copy [3][0]Item,&mut i32)void"(ptr noundef nonnull align 4 %target, ptr noundef nonnull align 4 %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 4 ptr @"cw:ZeroSource:func(&copy [3][0]Item,&mut i32)&copy [3][0]Item"(ptr noundef nonnull align 4 %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load ptr, ptr %counter.addr, align 8
  %call1 = call noundef nonnull align 4 ptr @"cw:ZeroTarget:func(&mut [3][0]Item,&mut i32)&mut [3][0]Item"(ptr noundef nonnull align 4 %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  ret void
}

define noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Empty:ctor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Empty:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Empty:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"cw:operator=:func(&mut Empty,&copy Empty)void"(ptr noundef nonnull align 1 dereferenceable(1) %target, ptr noundef nonnull align 1 dereferenceable(1) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  ret void
}

define void @"cw:EmptyElements:func(&mut [2]Empty,&copy [2]Empty)void"(ptr noundef nonnull align 1 dereferenceable(2) %target, ptr noundef nonnull align 1 dereferenceable(2) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %array.assign, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.assign ]
  %element = getelementptr inbounds nuw [2 x %struct.Empty], ptr %1, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Empty], ptr %0, i64 0, i64 %array.index
  call void @"cw:operator=:func(&mut Empty,&copy Empty)void"(ptr noundef nonnull align 1 dereferenceable(1) %element, ptr noundef nonnull align 1 dereferenceable(1) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  ret void
}
