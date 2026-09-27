%struct.Item = type { i32 }
%struct.CopyOnly = type { i32 }
%struct.Empty = type { i8 }

define noundef ptr @Item.ctor(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @Item.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"="(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
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

define noundef nonnull align 4 dereferenceable(4) ptr @"=.1"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
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

define noundef nonnull align 4 dereferenceable(8) ptr @Copy(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
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
  call void @"="(ptr noundef nonnull align 4 dereferenceable(4) %element, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 4 dereferenceable(8) ptr @Move(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
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
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"=.1"(ptr noundef nonnull align 4 dereferenceable(4) %element, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define void @Nested(ptr noundef nonnull align 4 dereferenceable(16) %target, ptr noundef nonnull align 4 dereferenceable(16) %source) {
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
  call void @"="(ptr noundef nonnull align 4 dereferenceable(4) %element5, ptr noundef nonnull align 4 dereferenceable(4) %element6)
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

define noundef ptr @CopyOnly.ctor(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.CopyOnly, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @CopyOnly.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef i32 @"=.2"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
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

define void @Fallback(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
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
  %call = call noundef i32 @"=.2"(ptr noundef nonnull align 4 dereferenceable(4) %element, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  ret void
}

define noundef nonnull align 4 ptr @ZeroSource(ptr noundef nonnull align 4 %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
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

define noundef nonnull align 4 ptr @ZeroTarget(ptr noundef nonnull align 4 %target, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
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

define void @NestedZero(ptr noundef nonnull align 4 %target, ptr noundef nonnull align 4 %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 4 ptr @ZeroSource(ptr noundef nonnull align 4 %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load ptr, ptr %counter.addr, align 8
  %call1 = call noundef nonnull align 4 ptr @ZeroTarget(ptr noundef nonnull align 4 %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  ret void
}

define noundef ptr @Empty.ctor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Empty.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"=.3"(ptr noundef nonnull align 1 dereferenceable(1) %target, ptr noundef nonnull align 1 dereferenceable(1) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  ret void
}

define void @EmptyElements(ptr noundef nonnull align 1 dereferenceable(2) %target, ptr noundef nonnull align 1 dereferenceable(2) %source) {
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
  call void @"=.3"(ptr noundef nonnull align 1 dereferenceable(1) %element, ptr noundef nonnull align 1 dereferenceable(1) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  ret void
}
