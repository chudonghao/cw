%struct.Derived = type { %struct.Base }
%struct.Base = type { ptr }

@"cw:Base:vtable" = constant [3 x ptr] [ptr null, ptr null, ptr @__cxa_pure_virtual], align 8
@"cw:Derived:vtable" = constant [3 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Derived)i32"], align 8

; Function Attrs: noreturn
declare void @__cxa_pure_virtual() #0

define noundef i32 @"cw:Read:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 9, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Base:ctor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
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

define noundef i32 @"cw:Invoke:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %object) {
entry:
  %.result = alloca i32, align 4
  %object.addr = alloca ptr, align 8
  store ptr %object, ptr %object.addr, align 8
  %0 = load ptr, ptr %object.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  %call1 = call noundef i32 @"cw:Invoke:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  %call1 = call noundef i32 @"cw:Invoke:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef i32 @"cw:Check:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %object = alloca %struct.Derived, align 8
  %call = call noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %object)
  %call1 = call noundef i32 @"cw:Invoke:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %object)
  %call2 = call noundef i32 @"cw:Read:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %object)
  %add = add i32 %call1, %call2
  store i32 %add, ptr %.result, align 4
  %call3 = call noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %object)
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

attributes #0 = { noreturn }
