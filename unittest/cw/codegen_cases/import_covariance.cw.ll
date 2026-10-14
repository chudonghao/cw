@"cw:Local:vtable" = constant [6 x ptr] [ptr null, ptr null, ptr @"cw:Pointer:func(&copy SpecialSource)*SpecialProduct:thunk(0,8)", ptr @"cw:Reference:func(&copy SpecialSource)&copy SpecialProduct:thunk(0,8)", ptr @"cw:Pointer:func(&copy SpecialSource)*SpecialProduct", ptr @"cw:Reference:func(&copy SpecialSource)&copy SpecialProduct"], align 8
@"cw:SpecialSource:vtable" = external constant [6 x ptr], align 8
@"cw:Another:vtable" = constant [6 x ptr] [ptr null, ptr null, ptr @"cw:Pointer:func(&copy SpecialSource)*SpecialProduct:thunk(0,8)", ptr @"cw:Reference:func(&copy SpecialSource)&copy SpecialProduct:thunk(0,8)", ptr @"cw:Pointer:func(&copy SpecialSource)*SpecialProduct", ptr @"cw:Reference:func(&copy SpecialSource)&copy SpecialProduct"], align 8

; Function Attrs: noreturn
declare void @__cxa_pure_virtual() #0

declare noundef ptr @"cw:Product:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Product:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:SpecialProduct:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:SpecialProduct:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Source:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Source:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:SpecialSource:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:SpecialSource:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:SpecialSource:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:SpecialSource:dtor():base"(ptr noundef returned)

define noundef ptr @"cw:Local:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:SpecialSource:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([6 x ptr], ptr @"cw:Local:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Local:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:SpecialSource:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([6 x ptr], ptr @"cw:Local:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Local:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([6 x ptr], ptr @"cw:Local:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([6 x ptr], ptr @"cw:SpecialSource:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:SpecialSource:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Local:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([6 x ptr], ptr @"cw:Local:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([6 x ptr], ptr @"cw:SpecialSource:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:SpecialSource:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:PointerCall:func(&copy Source)*Product"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef ptr %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:ReferenceCall:func(&copy Source)&copy Product"(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 1
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @"cw:Another:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:SpecialSource:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([6 x ptr], ptr @"cw:Another:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Another:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:SpecialSource:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr ([6 x ptr], ptr @"cw:Another:vtable", i64 0, i64 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Another:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([6 x ptr], ptr @"cw:Another:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([6 x ptr], ptr @"cw:SpecialSource:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:SpecialSource:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Another:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([6 x ptr], ptr @"cw:Another:vtable", i64 0, i64 2), ptr %this, align 8
  store ptr getelementptr ([6 x ptr], ptr @"cw:SpecialSource:vtable", i64 0, i64 2), ptr %this, align 8
  %call = call noundef ptr @"cw:SpecialSource:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

declare noundef ptr @"cw:Pointer:func(&copy SpecialSource)*SpecialProduct"(ptr noundef nonnull align 8 dereferenceable(8))

define internal noundef ptr @"cw:Pointer:func(&copy SpecialSource)*SpecialProduct:thunk(0,8)"(ptr noundef %0) {
entry:
  %call = call noundef ptr @"cw:Pointer:func(&copy SpecialSource)*SpecialProduct"(ptr noundef nonnull align 8 dereferenceable(8) %0)
  %return.adjusted = getelementptr inbounds nuw i8, ptr %call, i64 8
  %1 = icmp eq ptr %call, null
  %return.nullable = select i1 %1, ptr null, ptr %return.adjusted
  ret ptr %return.nullable
}

declare noundef nonnull align 8 dereferenceable(12) ptr @"cw:Reference:func(&copy SpecialSource)&copy SpecialProduct"(ptr noundef nonnull align 8 dereferenceable(8))

define internal noundef ptr @"cw:Reference:func(&copy SpecialSource)&copy SpecialProduct:thunk(0,8)"(ptr noundef %0) {
entry:
  %call = call noundef nonnull align 8 dereferenceable(12) ptr @"cw:Reference:func(&copy SpecialSource)&copy SpecialProduct"(ptr noundef nonnull align 8 dereferenceable(8) %0)
  %return.adjusted = getelementptr inbounds nuw i8, ptr %call, i64 8
  ret ptr %return.adjusted
}

attributes #0 = { noreturn }
