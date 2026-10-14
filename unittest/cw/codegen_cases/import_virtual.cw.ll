%struct.Derived = type { %"struct.api::Base" }
%"struct.api::Base" = type { ptr }

@"cw:Derived:vtable" = constant [5 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Derived)i32", ptr @"cw:api::Keep:func(&copy api::Base)i32", ptr @"cw:api::Hidden:func(&copy api::Base)i32"], align 8
@"cw:api::Base:vtable" = external constant [5 x ptr], align 8

declare noundef ptr @"cw:api::Base:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:api::Base:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:api::Base:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:api::Base:dtor():base"(ptr noundef returned)

declare noundef i32 @"cw:api::Keep:func(&copy api::Base)i32"(ptr noundef nonnull align 8 dereferenceable(8))

define noundef i32 @"cw:Read:func(&copy Derived)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 2, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:api::Base:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([5 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:api::Base:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([5 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([5 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([5 x ptr], ptr @"cw:api::Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:api::Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([5 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([5 x ptr], ptr @"cw:api::Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:api::Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef i32 @"cw:Dispatch:func(&copy api::Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:Direct:func(&copy api::Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:api::Keep:func(&copy api::Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef ptr @"cw:Address:func()*func(&copy api::Base)i32"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:api::Keep:func(&copy api::Base)i32", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef i32 @"cw:Slot:func(&copy api::Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %callback = alloca { i64, i64 }, align 8
  store ptr %value, ptr %value.addr, align 8
  store { i64, i64 } { i64 16, i64 1 }, ptr %callback, align 8
  %0 = load { i64, i64 }, ptr %callback, align 8
  %1 = load ptr, ptr %value.addr, align 8
  %2 = extractvalue { i64, i64 } %0, 1
  %this.adjustment = ashr i64 %2, 1
  %virtual.this = getelementptr i8, ptr %1, i64 %this.adjustment
  %vtable = load ptr, ptr %virtual.this, align 8
  %slot.offset = extractvalue { i64, i64 } %0, 0
  %virtual.slot = getelementptr i8, ptr %vtable, i64 %slot.offset
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %virtual.this)
  store i32 %call, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:Use:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %value = alloca %struct.Derived, align 8
  %call = call noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %value)
  %call1 = call noundef i32 @"cw:Dispatch:func(&copy api::Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %value)
  store i32 %call1, ptr %.result, align 4
  %call2 = call noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %value)
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

declare noundef i32 @"cw:api::Hidden:func(&copy api::Base)i32"(ptr noundef nonnull align 8 dereferenceable(8))
