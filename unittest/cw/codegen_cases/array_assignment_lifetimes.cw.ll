%struct.Receipt = type { ptr }
%struct.Item = type { ptr }
%struct.Token = type { ptr, i32 }

define noundef ptr @Receipt.ctor(ptr noundef returned %this, ptr noundef %trace) {
entry:
  %trace.addr = alloca ptr, align 8
  store ptr %trace, ptr %trace.addr, align 8
  %trace1 = getelementptr inbounds nuw %struct.Receipt, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %trace.addr, align 8
  store ptr %0, ptr %trace1, align 8
  ret ptr %this
}

define noundef ptr @Receipt.dtor(ptr noundef returned %this) {
entry:
  %trace = getelementptr inbounds nuw %struct.Receipt, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %trace, align 8
  %1 = load i32, ptr %0, align 4
  %mul = mul i32 %1, 10
  %add = add i32 %mul, 2
  %trace1 = getelementptr inbounds nuw %struct.Receipt, ptr %this, i32 0, i32 0
  %2 = load ptr, ptr %trace1, align 8
  store i32 %add, ptr %2, align 4
  ret ptr %this
}

define noundef ptr @Item.ctor(ptr noundef returned %this, ptr noundef %trace) {
entry:
  %trace.addr = alloca ptr, align 8
  store ptr %trace, ptr %trace.addr, align 8
  %trace1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %trace.addr, align 8
  store ptr %0, ptr %trace1, align 8
  ret ptr %this
}

define noundef ptr @Item.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"="(ptr sret(%struct.Receipt) align 8 %.result, ptr noundef nonnull align 8 dereferenceable(8) %target, ptr noundef nonnull align 8 dereferenceable(8) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8
  %trace = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load ptr, ptr %trace, align 8
  %2 = load i32, ptr %1, align 4
  %mul = mul i32 %2, 10
  %add = add i32 %mul, 1
  %3 = load ptr, ptr %target.addr, align 8
  %trace1 = getelementptr inbounds nuw %struct.Item, ptr %3, i32 0, i32 0
  %4 = load ptr, ptr %trace1, align 8
  store i32 %add, ptr %4, align 4
  %5 = load ptr, ptr %target.addr, align 8
  %trace2 = getelementptr inbounds nuw %struct.Item, ptr %5, i32 0, i32 0
  %6 = load ptr, ptr %trace2, align 8
  %call = call noundef ptr @Receipt.ctor(ptr noundef returned %.result, ptr noundef %6)
  ret void
}

define noundef ptr @Token.ctor(ptr noundef returned %this, ptr noundef %trace, i32 noundef %tag) {
entry:
  %trace.addr = alloca ptr, align 8
  %tag.addr = alloca i32, align 4
  store ptr %trace, ptr %trace.addr, align 8
  store i32 %tag, ptr %tag.addr, align 4
  %trace1 = getelementptr inbounds nuw %struct.Token, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %trace.addr, align 8
  store ptr %0, ptr %trace1, align 8
  %tag2 = getelementptr inbounds nuw %struct.Token, ptr %this, i32 0, i32 1
  %1 = load i32, ptr %tag.addr, align 4
  store i32 %1, ptr %tag2, align 8
  %2 = load ptr, ptr %trace.addr, align 8
  %3 = load i32, ptr %2, align 4
  %mul = mul i32 %3, 10
  %4 = load i32, ptr %tag.addr, align 4
  %add = add i32 %mul, %4
  %5 = load ptr, ptr %trace.addr, align 8
  store i32 %add, ptr %5, align 4
  ret ptr %this
}

define noundef ptr @Token.dtor(ptr noundef returned %this) {
entry:
  %trace = getelementptr inbounds nuw %struct.Token, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %trace, align 8
  %1 = load i32, ptr %0, align 4
  %mul = mul i32 %1, 10
  %tag = getelementptr inbounds nuw %struct.Token, ptr %this, i32 0, i32 1
  %2 = load i32, ptr %tag, align 8
  %add = add i32 %mul, %2
  %trace1 = getelementptr inbounds nuw %struct.Token, ptr %this, i32 0, i32 0
  %3 = load ptr, ptr %trace1, align 8
  store i32 %add, ptr %3, align 4
  ret ptr %this
}

define noundef nonnull align 8 dereferenceable(16) ptr @Source(ptr noundef nonnull align 8 dereferenceable(16) %source, ptr noundef nonnull align 8 dereferenceable(12) %token) {
entry:
  %.result = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %token.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %token, ptr %token.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 8 dereferenceable(16) ptr @Target(ptr noundef nonnull align 8 dereferenceable(16) %target, ptr noundef nonnull align 8 dereferenceable(12) %token) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %token.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %token, ptr %token.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @Assign(ptr noundef nonnull align 8 dereferenceable(16) %target, ptr noundef nonnull align 8 dereferenceable(16) %source, ptr noundef nonnull align 4 dereferenceable(4) %trace) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %trace.addr = alloca ptr, align 8
  %temporary = alloca %struct.Token, align 8
  %temporary2 = alloca %struct.Token, align 8
  %call.result = alloca %struct.Receipt, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %trace, ptr %trace.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %trace.addr, align 8
  %call = call noundef ptr @Token.ctor(ptr noundef returned %temporary, ptr noundef %1, i32 noundef 4)
  %call1 = call noundef nonnull align 8 dereferenceable(16) ptr @Source(ptr noundef nonnull align 8 dereferenceable(16) %0, ptr noundef nonnull align 8 dereferenceable(12) %temporary)
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load ptr, ptr %trace.addr, align 8
  %call3 = call noundef ptr @Token.ctor(ptr noundef returned %temporary2, ptr noundef %3, i32 noundef 5)
  %call4 = call noundef nonnull align 8 dereferenceable(16) ptr @Target(ptr noundef nonnull align 8 dereferenceable(16) %2, ptr noundef nonnull align 8 dereferenceable(12) %temporary2)
  br label %array.assign

array.assign:                                     ; preds = %array.assign, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.assign ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %call4, i64 0, i64 %array.index
  %element5 = getelementptr inbounds nuw [2 x %struct.Item], ptr %call1, i64 0, i64 %array.index
  call void @"="(ptr sret(%struct.Receipt) align 8 %call.result, ptr noundef nonnull align 8 dereferenceable(8) %element, ptr noundef nonnull align 8 dereferenceable(8) %element5)
  %call6 = call noundef ptr @Receipt.dtor(ptr noundef returned %call.result)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %array.assign
  %call7 = call noundef ptr @Token.dtor(ptr noundef returned %temporary2)
  %call8 = call noundef ptr @Token.dtor(ptr noundef returned %temporary)
  ret void
}

define void @Conditional(i1 noundef zeroext %flag, ptr noundef nonnull align 8 dereferenceable(16) %target, ptr noundef nonnull align 8 dereferenceable(16) %source) {
entry:
  %flag.addr = alloca i8, align 1
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %call.result = alloca %struct.Receipt, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %source.addr, align 8
  %2 = load ptr, ptr %target.addr, align 8
  br label %array.assign

array.assign:                                     ; preds = %cleanup.end, %cond.true
  %array.index = phi i64 [ 0, %cond.true ], [ %array.next, %cleanup.end ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %2, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Item], ptr %1, i64 0, i64 %array.index
  call void @"="(ptr sret(%struct.Receipt) align 8 %call.result, ptr noundef nonnull align 8 dereferenceable(8) %element, ptr noundef nonnull align 8 dereferenceable(8) %element1)
  br i1 %loadedv, label %cleanup.destroy, label %cleanup.end

cleanup.destroy:                                  ; preds = %array.assign
  %call = call noundef ptr @Receipt.dtor(ptr noundef returned %call.result)
  br label %cleanup.end

cleanup.end:                                      ; preds = %cleanup.destroy, %array.assign
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.assign

array.end:                                        ; preds = %cleanup.end
  br label %cond.end

cond.false:                                       ; preds = %entry
  %3 = load ptr, ptr %target.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %array.end
  ret void
}
