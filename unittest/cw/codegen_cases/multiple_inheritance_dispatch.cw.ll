%struct.Both = type { %struct.Left.base, [4 x i8], %struct.Right.base, [4 x i8] }
%struct.Left.base = type <{ ptr, i32 }>
%struct.Right.base = type <{ %struct.Tag, %struct.Inner, i32 }>
%struct.Tag = type { ptr }
%struct.Inner = type { ptr }
%struct.Right = type { %struct.Tag, %struct.Inner, i32 }

@"cw:Both:vtable" = constant { [4 x ptr], [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @"cw:Name:func(&copy Both)i32", ptr @"cw:Size:func(&copy Both)i32"], [4 x ptr] [ptr inttoptr (i64 -16 to ptr), ptr null, ptr @"cw:Size:func(&copy Both)i32:thunk(-16,0)", ptr @"cw:Name:func(&copy Both)i32:thunk(-16,0)"], [3 x ptr] [ptr inttoptr (i64 -24 to ptr), ptr null, ptr @__cxa_pure_virtual] }, align 8
@"cw:Left:vtable" = external constant { [3 x ptr] }, align 8
@"cw:Right:vtable" = external constant { [4 x ptr], [3 x ptr] }, align 8
@"cw:Child:vtable" = constant { [4 x ptr], [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @"cw:Name:func(&copy Both)i32", ptr @"cw:Size:func(&copy Both)i32"], [4 x ptr] [ptr inttoptr (i64 -16 to ptr), ptr null, ptr @"cw:Size:func(&copy Both)i32:thunk(-16,0)", ptr @"cw:Name:func(&copy Both)i32:thunk(-16,0)"], [3 x ptr] [ptr inttoptr (i64 -24 to ptr), ptr null, ptr @__cxa_pure_virtual] }, align 8

; Function Attrs: noreturn
declare void @__cxa_pure_virtual() #0

declare noundef ptr @"cw:Left:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Left:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:Left:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Left:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Tag:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Tag:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Inner:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Inner:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Right:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Right:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:Right:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Right:dtor():base"(ptr noundef returned)

declare noundef i32 @"cw:Name:func(&copy Right)i32"(ptr noundef nonnull align 8 dereferenceable(20))

define noundef i32 @"cw:Name:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(36) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 1, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:Size:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(36) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 2, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Both:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Left:ctor():base"(ptr noundef returned %this)
  %base = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  %call1 = call noundef ptr @"cw:Right:ctor():base"(ptr noundef returned %base)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable.field2 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 2, i32 2), ptr %vtable.field2, align 8
  ret ptr %this
}

define noundef ptr @"cw:Both:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Left:ctor():base"(ptr noundef returned %this)
  %base = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  %call1 = call noundef ptr @"cw:Right:ctor():base"(ptr noundef returned %base)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable.field2 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 2, i32 2), ptr %vtable.field2, align 8
  ret ptr %this
}

define noundef ptr @"cw:Both:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable.field1 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 2, i32 2), ptr %vtable.field1, align 8
  %base = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  %base2 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Left:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Right:vtable", i32 0, i32 0, i32 2), ptr %base2, align 8
  %vtable.field3 = getelementptr inbounds nuw i8, ptr %base2, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Right:vtable", i32 0, i32 1, i32 2), ptr %vtable.field3, align 8
  %call = call noundef ptr @"cw:Right:dtor():base"(ptr noundef returned %base)
  %call4 = call noundef ptr @"cw:Left:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Both:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable.field1 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 2, i32 2), ptr %vtable.field1, align 8
  %base = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  %base2 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Left:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Right:vtable", i32 0, i32 0, i32 2), ptr %base2, align 8
  %vtable.field3 = getelementptr inbounds nuw i8, ptr %base2, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Right:vtable", i32 0, i32 1, i32 2), ptr %vtable.field3, align 8
  %call = call noundef ptr @"cw:Right:dtor():base"(ptr noundef returned %base)
  %call4 = call noundef ptr @"cw:Left:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Child:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Both:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable.field1 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 2, i32 2), ptr %vtable.field1, align 8
  ret ptr %this
}

define noundef ptr @"cw:Child:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Both:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable.field1 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 2, i32 2), ptr %vtable.field1, align 8
  ret ptr %this
}

define noundef ptr @"cw:Child:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable.field1 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 2, i32 2), ptr %vtable.field1, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field2 = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field2, align 8
  %vtable.field3 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 2, i32 2), ptr %vtable.field3, align 8
  %call = call noundef ptr @"cw:Both:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Child:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable.field1 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Child:vtable", i32 0, i32 2, i32 2), ptr %vtable.field1, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field2 = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field2, align 8
  %vtable.field3 = getelementptr inbounds nuw i8, ptr %this, i64 24
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 2, i32 2), ptr %vtable.field3, align 8
  %call = call noundef ptr @"cw:Both:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef i32 @"cw:ReadDeep:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(36) %both) {
entry:
  %.result = alloca i32, align 4
  %both.addr = alloca ptr, align 8
  store ptr %both, ptr %both.addr, align 8
  %0 = load ptr, ptr %both.addr, align 8
  %base = getelementptr inbounds nuw %struct.Both, ptr %0, i32 0, i32 2
  %base1 = getelementptr inbounds nuw %struct.Right, ptr %base, i32 0, i32 1
  %vtable = load ptr, ptr %base1, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %base1)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:ViaPointer:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(36) %both) {
entry:
  %.result = alloca i32, align 4
  %both.addr = alloca ptr, align 8
  %size = alloca { i64, i64 }, align 8
  store ptr %both, ptr %both.addr, align 8
  store { i64, i64 } { i64 0, i64 1 }, ptr %size, align 8
  %0 = load { i64, i64 }, ptr %size, align 8
  %1 = load ptr, ptr %both.addr, align 8
  %base = getelementptr inbounds nuw %struct.Both, ptr %1, i32 0, i32 2
  %2 = extractvalue { i64, i64 } %0, 1
  %this.adjustment = ashr i64 %2, 1
  %virtual.this = getelementptr i8, ptr %base, i64 %this.adjustment
  %vtable = load ptr, ptr %virtual.this, align 8
  %slot.offset = extractvalue { i64, i64 } %0, 0
  %virtual.slot = getelementptr i8, ptr %vtable, i64 %slot.offset
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %virtual.this)
  store i32 %call, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:Direct:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(36) %both) {
entry:
  %.result = alloca i32, align 4
  %both.addr = alloca ptr, align 8
  store ptr %both, ptr %both.addr, align 8
  %0 = load ptr, ptr %both.addr, align 8
  %base = getelementptr inbounds nuw %struct.Both, ptr %0, i32 0, i32 2
  %call = call noundef i32 @"cw:Name:func(&copy Right)i32"(ptr noundef nonnull align 8 dereferenceable(20) %base)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define internal noundef i32 @"cw:Size:func(&copy Both)i32:thunk(-16,0)"(ptr noundef %0) {
entry:
  %this.adjusted = getelementptr inbounds i8, ptr %0, i64 -16
  %call = call noundef i32 @"cw:Size:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(36) %this.adjusted)
  ret i32 %call
}

define internal noundef i32 @"cw:Name:func(&copy Both)i32:thunk(-16,0)"(ptr noundef %0) {
entry:
  %this.adjusted = getelementptr inbounds i8, ptr %0, i64 -16
  %call = call noundef i32 @"cw:Name:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(36) %this.adjusted)
  ret i32 %call
}

attributes #0 = { noreturn }
