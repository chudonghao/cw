%struct.Item = type { ptr, i32 }

@.cw.vtable.Item = internal constant [4 x ptr] [ptr null, ptr null, ptr @First, ptr @Second], align 8

define noundef i32 @First(ptr noundef nonnull align 8 dereferenceable(12) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %0 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 1
  %1 = load i32, ptr %value, align 8
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Second(ptr noundef nonnull align 8 dereferenceable(12) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %0 = load ptr, ptr %this.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 1
  %1 = load i32, ptr %value, align 8
  %add = add i32 %1, 10
  store i32 %add, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef ptr @Item.ctor(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 1
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 8
  store ptr getelementptr ([4 x ptr], ptr @.cw.vtable.Item, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @Item.dtor(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @.cw.vtable.Item, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef [2 x i64] @Identity([2 x i64] noundef %pointer) {
entry:
  %.result = alloca [2 x i64], align 8
  %pointer.addr = alloca [2 x i64], align 8
  store [2 x i64] %pointer, ptr %pointer.addr, align 8
  %0 = load [2 x i64], ptr %pointer.addr, align 8
  store [2 x i64] %0, ptr %.result, align 8
  %1 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %1
}

define noundef nonnull align 8 dereferenceable(12) ptr @Replace(ptr noundef nonnull align 8 dereferenceable(16) %pointer, ptr noundef nonnull align 8 dereferenceable(12) %item) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %item.addr = alloca ptr, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %item, ptr %item.addr, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  store [2 x i64] [i64 8, i64 1], ptr %0, align 8
  %1 = load ptr, ptr %item.addr, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @Invoke(ptr noundef nonnull align 8 dereferenceable(12) %item) {
entry:
  %.result = alloca i32, align 4
  %item.addr = alloca ptr, align 8
  %pointer = alloca [2 x i64], align 8
  %copied = alloca [2 x i64], align 8
  %direct = alloca ptr, align 8
  %result = alloca i32, align 4
  store ptr %item, ptr %item.addr, align 8
  %call = call noundef [2 x i64] @Identity([2 x i64] noundef [i64 0, i64 1])
  store [2 x i64] %call, ptr %pointer, align 8
  %0 = load [2 x i64], ptr %pointer, align 8
  store [2 x i64] %0, ptr %copied, align 8
  store ptr @First, ptr %direct, align 8
  %1 = load [2 x i64], ptr %pointer, align 8
  %2 = load ptr, ptr %item.addr, align 8
  %call1 = call noundef nonnull align 8 dereferenceable(12) ptr @Replace(ptr noundef nonnull align 8 dereferenceable(16) %pointer, ptr noundef nonnull align 8 dereferenceable(12) %2)
  %3 = extractvalue [2 x i64] %1, 1
  %this.adjustment = ashr i64 %3, 1
  %virtual.this = getelementptr i8, ptr %call1, i64 %this.adjustment
  %vtable = load ptr, ptr %virtual.this, align 8
  %4 = extractvalue [2 x i64] %1, 0
  %5 = trunc i64 %4 to i32
  %slot.offset = zext i32 %5 to i64
  %virtual.slot = getelementptr i8, ptr %vtable, i64 %slot.offset
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call2 = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(12) %virtual.this)
  store i32 %call2, ptr %result, align 4
  %6 = load i32, ptr %result, align 4
  %7 = load [2 x i64], ptr %pointer, align 8
  %8 = load ptr, ptr %item.addr, align 8
  %9 = extractvalue [2 x i64] %7, 1
  %this.adjustment3 = ashr i64 %9, 1
  %virtual.this4 = getelementptr i8, ptr %8, i64 %this.adjustment3
  %vtable5 = load ptr, ptr %virtual.this4, align 8
  %10 = extractvalue [2 x i64] %7, 0
  %11 = trunc i64 %10 to i32
  %slot.offset6 = zext i32 %11 to i64
  %virtual.slot7 = getelementptr i8, ptr %vtable5, i64 %slot.offset6
  %virtual.callee8 = load ptr, ptr %virtual.slot7, align 8
  %call9 = call noundef i32 %virtual.callee8(ptr noundef nonnull align 8 dereferenceable(12) %virtual.this4)
  %add = add i32 %6, %call9
  %12 = load [2 x i64], ptr %copied, align 8
  %13 = load ptr, ptr %item.addr, align 8
  %14 = extractvalue [2 x i64] %12, 1
  %this.adjustment10 = ashr i64 %14, 1
  %virtual.this11 = getelementptr i8, ptr %13, i64 %this.adjustment10
  %vtable12 = load ptr, ptr %virtual.this11, align 8
  %15 = extractvalue [2 x i64] %12, 0
  %16 = trunc i64 %15 to i32
  %slot.offset13 = zext i32 %16 to i64
  %virtual.slot14 = getelementptr i8, ptr %vtable12, i64 %slot.offset13
  %virtual.callee15 = load ptr, ptr %virtual.slot14, align 8
  %call16 = call noundef i32 %virtual.callee15(ptr noundef nonnull align 8 dereferenceable(12) %virtual.this11)
  %add17 = add i32 %add, %call16
  %17 = load ptr, ptr %direct, align 8
  %18 = load ptr, ptr %item.addr, align 8
  %call18 = call noundef i32 %17(ptr noundef nonnull align 8 dereferenceable(12) %18)
  %add19 = add i32 %add17, %call18
  store i32 %add19, ptr %.result, align 4
  %19 = load i32, ptr %.result, align 4
  ret i32 %19
}

define noundef i32 @Entry() {
entry:
  %.result = alloca i32, align 4
  %first = alloca %struct.Item, align 8
  %second = alloca %struct.Item, align 8
  %call = call noundef ptr @Item.ctor(ptr noundef returned %first, i32 noundef 3)
  %call1 = call noundef ptr @Item.ctor(ptr noundef returned %second, i32 noundef 7)
  %call2 = call noundef i32 @Invoke(ptr noundef nonnull align 8 dereferenceable(12) %first)
  %call3 = call noundef i32 @Invoke(ptr noundef nonnull align 8 dereferenceable(12) %second)
  %add = add i32 %call2, %call3
  store i32 %add, ptr %.result, align 4
  %call4 = call noundef ptr @Item.dtor(ptr noundef returned %second)
  %call5 = call noundef ptr @Item.dtor(ptr noundef returned %first)
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef zeroext i1 @Empty() {
entry:
  %.result = alloca i8, align 1
  %pointer = alloca [2 x i64], align 8
  store [2 x i64] zeroinitializer, ptr %pointer, align 8
  %0 = load [2 x i64], ptr %pointer, align 8
  %slot.offset = extractvalue [2 x i64] %0, 0
  %slot.adjustment = extractvalue [2 x i64] %0, 1
  %1 = icmp ne i64 %slot.offset, 0
  %2 = and i64 %slot.adjustment, 1
  %3 = icmp ne i64 %2, 0
  %slot.nonnull = or i1 %1, %3
  %cmp = icmp eq i1 %slot.nonnull, false
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %4, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @Present() {
entry:
  %.result = alloca i8, align 1
  %pointer = alloca [2 x i64], align 8
  store [2 x i64] [i64 0, i64 1], ptr %pointer, align 8
  %0 = load [2 x i64], ptr %pointer, align 8
  %slot.offset = extractvalue [2 x i64] %0, 0
  %slot.adjustment = extractvalue [2 x i64] %0, 1
  %1 = icmp ne i64 %slot.offset, 0
  %2 = and i64 %slot.adjustment, 1
  %3 = icmp ne i64 %2, 0
  %slot.nonnull = or i1 %1, %3
  %cmp = icmp ne i1 false, %slot.nonnull
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %4, 0
  ret i1 %loadedv
}
