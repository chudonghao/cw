; Function Attrs: noreturn
declare void @__cxa_pure_virtual() #0

declare noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Base:dtor():base"(ptr noundef returned)

declare void @"cw:Unused:func()void"()

define noundef i32 @"cw:Dispatch:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  %1 = load ptr, ptr %value.addr, align 8
  %vtable1 = load ptr, ptr %1, align 8
  %virtual.slot2 = getelementptr inbounds ptr, ptr %vtable1, i64 1
  %virtual.callee3 = load ptr, ptr %virtual.slot2, align 8
  %call4 = call noundef i32 %virtual.callee3(ptr noundef nonnull align 8 dereferenceable(8) %1)
  %add = add i32 %call, %call4
  store i32 %add, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef [2 x i64] @"cw:Slot:func()virtual *func(&copy Base)i32"() {
entry:
  %.result = alloca { i64, i64 }, align 8
  store { i64, i64 } { i64 0, i64 1 }, ptr %.result, align 8
  %0 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %0
}

attributes #0 = { noreturn }
