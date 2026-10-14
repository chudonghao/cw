%struct.Derived = type { %struct.Base }
%struct.Base = type { ptr }

@"cw:Base:vtable" = constant [4 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Base)i32", ptr @"cw:Keep:func(&copy Base)i32"], align 8
@"cw:Derived:vtable" = constant [4 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Derived)i32", ptr @"cw:Keep:func(&copy Base)i32"], align 8

define noundef i32 @"cw:Read:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 1, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:Keep:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 5, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:Read:func(&copy Derived)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 2, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Base:ctor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([4 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([4 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([4 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([4 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef i32 @"cw:ReadBase:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %object) {
entry:
  %.result = alloca i32, align 4
  %object.addr = alloca ptr, align 8
  store ptr %object, ptr %object.addr, align 8
  %0 = load ptr, ptr %object.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  %1 = load ptr, ptr %object.addr, align 8
  %vtable1 = load ptr, ptr %1, align 8
  %virtual.slot2 = getelementptr inbounds ptr, ptr %vtable1, i64 0
  %virtual.callee3 = load ptr, ptr %virtual.slot2, align 8
  %call4 = call noundef i32 %virtual.callee3(ptr noundef nonnull align 8 dereferenceable(8) %1)
  %add = add i32 %call, %call4
  store i32 %add, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:Entry:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %value = alloca %struct.Derived, align 8
  %call = call noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %value)
  %call1 = call noundef i32 @"cw:ReadBase:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %value)
  %vtable = load ptr, ptr %value, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 1
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call2 = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %value)
  %add = add i32 %call1, %call2
  %call3 = call noundef i32 @"cw:Read:func(&copy Derived)i32"(ptr noundef nonnull align 8 dereferenceable(8) %value)
  %add4 = add i32 %add, %call3
  %call5 = call noundef i32 @"cw:Read:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %value)
  %add6 = add i32 %add4, %call5
  store i32 %add6, ptr %.result, align 4
  %call7 = call noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %value)
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
