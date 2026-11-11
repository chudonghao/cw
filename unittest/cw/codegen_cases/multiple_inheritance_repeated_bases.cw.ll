%struct.D = type { %struct.B.base, [4 x i8], %struct.C.base, [4 x i8] }
%struct.B.base = type { %struct.A.base }
%struct.A.base = type <{ ptr, i32 }>
%struct.C.base = type { %struct.A.base }

@"cw:D:vtable" = constant { [4 x ptr], [4 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @"cw:F:func(&copy B)i32", ptr @"cw:G:func(&copy D)i32"], [4 x ptr] [ptr inttoptr (i64 -16 to ptr), ptr null, ptr @"cw:F:func(&copy A)i32", ptr @"cw:G:func(&copy D)i32:thunk(-16,0)"] }, align 8
@"cw:B:vtable" = external constant { [3 x ptr] }, align 8
@"cw:C:vtable" = external constant { [4 x ptr] }, align 8

declare noundef ptr @"cw:A:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:A:dtor():base"(ptr noundef returned)

declare noundef i32 @"cw:F:func(&copy A)i32"(ptr noundef nonnull align 8 dereferenceable(12))

declare noundef ptr @"cw:B:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:B:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:B:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:B:dtor():base"(ptr noundef returned)

declare noundef i32 @"cw:F:func(&copy B)i32"(ptr noundef nonnull align 8 dereferenceable(12))

declare noundef ptr @"cw:C:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:C:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:C:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:C:dtor():base"(ptr noundef returned)

define noundef i32 @"cw:G:func(&copy D)i32"(ptr noundef nonnull align 8 dereferenceable(28) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 4, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:D:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:B:ctor():base"(ptr noundef returned %this)
  %base = getelementptr inbounds nuw %struct.D, ptr %this, i32 0, i32 2
  %call1 = call noundef ptr @"cw:C:ctor():base"(ptr noundef returned %base)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @"cw:D:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @"cw:D:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  ret ptr %this
}

define noundef ptr @"cw:D:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:B:ctor():base"(ptr noundef returned %this)
  %base = getelementptr inbounds nuw %struct.D, ptr %this, i32 0, i32 2
  %call1 = call noundef ptr @"cw:C:ctor():base"(ptr noundef returned %base)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @"cw:D:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @"cw:D:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  ret ptr %this
}

define noundef ptr @"cw:D:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @"cw:D:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @"cw:D:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %base = getelementptr inbounds nuw %struct.D, ptr %this, i32 0, i32 2
  %base1 = getelementptr inbounds nuw %struct.D, ptr %this, i32 0, i32 2
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:B:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr] }, ptr @"cw:C:vtable", i32 0, i32 0, i32 2), ptr %base1, align 8
  %call = call noundef ptr @"cw:C:dtor():base"(ptr noundef returned %base)
  %call2 = call noundef ptr @"cw:B:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:D:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @"cw:D:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 16
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [4 x ptr] }, ptr @"cw:D:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %base = getelementptr inbounds nuw %struct.D, ptr %this, i32 0, i32 2
  %base1 = getelementptr inbounds nuw %struct.D, ptr %this, i32 0, i32 2
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:B:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr] }, ptr @"cw:C:vtable", i32 0, i32 0, i32 2), ptr %base1, align 8
  %call = call noundef ptr @"cw:C:dtor():base"(ptr noundef returned %base)
  %call2 = call noundef ptr @"cw:B:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef i32 @"cw:ReadThroughC:func(&copy D)i32"(ptr noundef nonnull align 8 dereferenceable(28) %d) {
entry:
  %.result = alloca i32, align 4
  %d.addr = alloca ptr, align 8
  store ptr %d, ptr %d.addr, align 8
  %0 = load ptr, ptr %d.addr, align 8
  %base = getelementptr inbounds nuw %struct.D, ptr %0, i32 0, i32 2
  %vtable = load ptr, ptr %base, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(12) %base)
  %1 = load ptr, ptr %d.addr, align 8
  %base1 = getelementptr inbounds nuw %struct.D, ptr %1, i32 0, i32 2
  %vtable2 = load ptr, ptr %base1, align 8
  %virtual.slot3 = getelementptr inbounds ptr, ptr %vtable2, i64 1
  %virtual.callee4 = load ptr, ptr %virtual.slot3, align 8
  %call5 = call noundef i32 %virtual.callee4(ptr noundef nonnull align 8 dereferenceable(12) %base1)
  %add = add i32 %call, %call5
  store i32 %add, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define internal noundef i32 @"cw:G:func(&copy D)i32:thunk(-16,0)"(ptr noundef %0) {
entry:
  %this.adjusted = getelementptr inbounds i8, ptr %0, i64 -16
  %call = call noundef i32 @"cw:G:func(&copy D)i32"(ptr noundef nonnull align 8 dereferenceable(28) %this.adjusted)
  ret i32 %call
}
