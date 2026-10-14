%struct.Item = type { ptr, i32 }

@"cw:Item:vtable" = constant [4 x ptr] [ptr null, ptr null, ptr @"cw:First:func(&copy Item)i32", ptr @"cw:Second:func(&copy Item)i32"], align 8

define noundef i32 @"cw:First:func(&copy Item)i32"(ptr noundef nonnull align 8 dereferenceable(12) %this) {
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

define noundef i32 @"cw:Second:func(&copy Item)i32"(ptr noundef nonnull align 8 dereferenceable(12) %this) {
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

define noundef ptr @"cw:Item:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 1
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 8
  store ptr getelementptr ([4 x ptr], ptr @"cw:Item:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 1
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 8
  store ptr getelementptr ([4 x ptr], ptr @"cw:Item:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @"cw:Item:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Item:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @"cw:Item:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef [2 x i64] @"cw:Identity:func(virtual *func(&copy Item)i32)virtual *func(&copy Item)i32"([2 x i64] noundef %pointer.coerce) {
entry:
  %.result = alloca { i64, i64 }, align 8
  %pointer = alloca { i64, i64 }, align 8
  store [2 x i64] %pointer.coerce, ptr %pointer, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %pointer, i64 16, i1 false)
  %0 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %0
}

define noundef nonnull align 8 dereferenceable(12) ptr @"cw:Replace:func(&mut virtual *func(&copy Item)i32,&copy Item)&copy Item"(ptr noundef nonnull align 8 dereferenceable(16) %pointer, ptr noundef nonnull align 8 dereferenceable(12) %item) {
entry:
  %.result = alloca ptr, align 8
  %pointer.addr = alloca ptr, align 8
  %item.addr = alloca ptr, align 8
  %assignment = alloca { i64, i64 }, align 8
  store ptr %pointer, ptr %pointer.addr, align 8
  store ptr %item, ptr %item.addr, align 8
  store { i64, i64 } { i64 8, i64 1 }, ptr %assignment, align 8
  %0 = load ptr, ptr %pointer.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %0, ptr align 8 %assignment, i64 16, i1 false)
  %1 = load ptr, ptr %item.addr, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @"cw:Invoke:func(&copy Item)i32"(ptr noundef nonnull align 8 dereferenceable(12) %item) {
entry:
  %.result = alloca i32, align 4
  %item.addr = alloca ptr, align 8
  %pointer = alloca { i64, i64 }, align 8
  %argument = alloca { i64, i64 }, align 8
  %copied = alloca { i64, i64 }, align 8
  %direct = alloca ptr, align 8
  %result = alloca i32, align 4
  store ptr %item, ptr %item.addr, align 8
  store { i64, i64 } { i64 0, i64 1 }, ptr %argument, align 8
  %0 = load [2 x i64], ptr %argument, align 8
  %call = call noundef [2 x i64] @"cw:Identity:func(virtual *func(&copy Item)i32)virtual *func(&copy Item)i32"([2 x i64] noundef %0)
  store [2 x i64] %call, ptr %pointer, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %copied, ptr align 8 %pointer, i64 16, i1 false)
  store ptr @"cw:First:func(&copy Item)i32", ptr %direct, align 8
  %1 = load { i64, i64 }, ptr %pointer, align 8
  %2 = load ptr, ptr %item.addr, align 8
  %call1 = call noundef nonnull align 8 dereferenceable(12) ptr @"cw:Replace:func(&mut virtual *func(&copy Item)i32,&copy Item)&copy Item"(ptr noundef nonnull align 8 dereferenceable(16) %pointer, ptr noundef nonnull align 8 dereferenceable(12) %2)
  %3 = extractvalue { i64, i64 } %1, 1
  %this.adjustment = ashr i64 %3, 1
  %virtual.this = getelementptr i8, ptr %call1, i64 %this.adjustment
  %vtable = load ptr, ptr %virtual.this, align 8
  %slot.offset = extractvalue { i64, i64 } %1, 0
  %virtual.slot = getelementptr i8, ptr %vtable, i64 %slot.offset
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call2 = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(12) %virtual.this)
  store i32 %call2, ptr %result, align 4
  %4 = load i32, ptr %result, align 4
  %5 = load { i64, i64 }, ptr %pointer, align 8
  %6 = load ptr, ptr %item.addr, align 8
  %7 = extractvalue { i64, i64 } %5, 1
  %this.adjustment3 = ashr i64 %7, 1
  %virtual.this4 = getelementptr i8, ptr %6, i64 %this.adjustment3
  %vtable5 = load ptr, ptr %virtual.this4, align 8
  %slot.offset6 = extractvalue { i64, i64 } %5, 0
  %virtual.slot7 = getelementptr i8, ptr %vtable5, i64 %slot.offset6
  %virtual.callee8 = load ptr, ptr %virtual.slot7, align 8
  %call9 = call noundef i32 %virtual.callee8(ptr noundef nonnull align 8 dereferenceable(12) %virtual.this4)
  %add = add i32 %4, %call9
  %8 = load { i64, i64 }, ptr %copied, align 8
  %9 = load ptr, ptr %item.addr, align 8
  %10 = extractvalue { i64, i64 } %8, 1
  %this.adjustment10 = ashr i64 %10, 1
  %virtual.this11 = getelementptr i8, ptr %9, i64 %this.adjustment10
  %vtable12 = load ptr, ptr %virtual.this11, align 8
  %slot.offset13 = extractvalue { i64, i64 } %8, 0
  %virtual.slot14 = getelementptr i8, ptr %vtable12, i64 %slot.offset13
  %virtual.callee15 = load ptr, ptr %virtual.slot14, align 8
  %call16 = call noundef i32 %virtual.callee15(ptr noundef nonnull align 8 dereferenceable(12) %virtual.this11)
  %add17 = add i32 %add, %call16
  %11 = load ptr, ptr %direct, align 8
  %12 = load ptr, ptr %item.addr, align 8
  %call18 = call noundef i32 %11(ptr noundef nonnull align 8 dereferenceable(12) %12)
  %add19 = add i32 %add17, %call18
  store i32 %add19, ptr %.result, align 4
  %13 = load i32, ptr %.result, align 4
  ret i32 %13
}

define noundef i32 @"cw:Entry:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %first = alloca %struct.Item, align 8
  %second = alloca %struct.Item, align 8
  %call = call noundef ptr @"cw:Item:ctor(i32):complete"(ptr noundef returned %first, i32 noundef 3)
  %call1 = call noundef ptr @"cw:Item:ctor(i32):complete"(ptr noundef returned %second, i32 noundef 7)
  %call2 = call noundef i32 @"cw:Invoke:func(&copy Item)i32"(ptr noundef nonnull align 8 dereferenceable(12) %first)
  %call3 = call noundef i32 @"cw:Invoke:func(&copy Item)i32"(ptr noundef nonnull align 8 dereferenceable(12) %second)
  %add = add i32 %call2, %call3
  store i32 %add, ptr %.result, align 4
  %call4 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %second)
  %call5 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %first)
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef zeroext i1 @"cw:Empty:func()bool"() {
entry:
  %.result = alloca i8, align 1
  %pointer = alloca { i64, i64 }, align 8
  store { i64, i64 } zeroinitializer, ptr %pointer, align 8
  %0 = load { i64, i64 }, ptr %pointer, align 8
  %slot.offset = extractvalue { i64, i64 } %0, 0
  %slot.adjustment = extractvalue { i64, i64 } %0, 1
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

define noundef zeroext i1 @"cw:Present:func()bool"() {
entry:
  %.result = alloca i8, align 1
  %pointer = alloca { i64, i64 }, align 8
  store { i64, i64 } { i64 0, i64 1 }, ptr %pointer, align 8
  %0 = load { i64, i64 }, ptr %pointer, align 8
  %slot.offset = extractvalue { i64, i64 } %0, 0
  %slot.adjustment = extractvalue { i64, i64 } %0, 1
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

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
