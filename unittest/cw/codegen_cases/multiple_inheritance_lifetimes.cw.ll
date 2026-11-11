%struct.Both = type { %struct.Left, %struct.Right, %struct.Watch }
%struct.Left = type { ptr }
%struct.Right = type { ptr }
%struct.Watch = type { ptr }

@"cw:Both:vtable" = constant { [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Both)i32", ptr @"cw:Size:func(&copy Both)i32"], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr @"cw:Size:func(&copy Both)i32:thunk(-8,0)"] }, align 8
@"cw:Left:vtable" = external constant { [3 x ptr] }, align 8
@"cw:Right:vtable" = external constant { [3 x ptr] }, align 8

declare noundef ptr @"cw:Left:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Left:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:Left:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Left:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Right:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Right:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:Right:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Right:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Watch:ctor(*const Right):complete"(ptr noundef returned, ptr noundef)

declare noundef ptr @"cw:Watch:ctor(*const Right):base"(ptr noundef returned, ptr noundef)

declare noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Watch:dtor():base"(ptr noundef returned)

declare void @"cw:Record:func(i32)void"(i32 noundef)

define noundef i32 @"cw:Read:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(24) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 3, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:Size:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(24) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 4, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Both:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Left:ctor():base"(ptr noundef returned %this)
  %base = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @"cw:Right:ctor():base"(ptr noundef returned %base)
  %vtable = load ptr, ptr %this, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call2 = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %base3 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %vtable4 = load ptr, ptr %base3, align 8
  %virtual.slot5 = getelementptr inbounds ptr, ptr %vtable4, i64 0
  %virtual.callee6 = load ptr, ptr %virtual.slot5, align 8
  %call7 = call noundef i32 %virtual.callee6(ptr noundef nonnull align 8 dereferenceable(8) %base3)
  %add = add i32 %call2, %call7
  call void @"cw:Record:func(i32)void"(i32 noundef %add)
  %watch = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  %base8 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %call9 = call noundef ptr @"cw:Watch:ctor(*const Right):complete"(ptr noundef returned %watch, ptr noundef %base8)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable10 = load ptr, ptr %this, align 8
  %virtual.slot11 = getelementptr inbounds ptr, ptr %vtable10, i64 0
  %virtual.callee12 = load ptr, ptr %virtual.slot11, align 8
  %call13 = call noundef i32 %virtual.callee12(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %base14 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %vtable15 = load ptr, ptr %base14, align 8
  %virtual.slot16 = getelementptr inbounds ptr, ptr %vtable15, i64 0
  %virtual.callee17 = load ptr, ptr %virtual.slot16, align 8
  %call18 = call noundef i32 %virtual.callee17(ptr noundef nonnull align 8 dereferenceable(8) %base14)
  %add19 = add i32 %call13, %call18
  call void @"cw:Record:func(i32)void"(i32 noundef %add19)
  ret ptr %this
}

define noundef ptr @"cw:Both:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Left:ctor():base"(ptr noundef returned %this)
  %base = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @"cw:Right:ctor():base"(ptr noundef returned %base)
  %vtable = load ptr, ptr %this, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call2 = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %base3 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %vtable4 = load ptr, ptr %base3, align 8
  %virtual.slot5 = getelementptr inbounds ptr, ptr %vtable4, i64 0
  %virtual.callee6 = load ptr, ptr %virtual.slot5, align 8
  %call7 = call noundef i32 %virtual.callee6(ptr noundef nonnull align 8 dereferenceable(8) %base3)
  %add = add i32 %call2, %call7
  call void @"cw:Record:func(i32)void"(i32 noundef %add)
  %watch = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  %base8 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %call9 = call noundef ptr @"cw:Watch:ctor(*const Right):complete"(ptr noundef returned %watch, ptr noundef %base8)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %vtable10 = load ptr, ptr %this, align 8
  %virtual.slot11 = getelementptr inbounds ptr, ptr %vtable10, i64 0
  %virtual.callee12 = load ptr, ptr %virtual.slot11, align 8
  %call13 = call noundef i32 %virtual.callee12(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %base14 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %vtable15 = load ptr, ptr %base14, align 8
  %virtual.slot16 = getelementptr inbounds ptr, ptr %vtable15, i64 0
  %virtual.callee17 = load ptr, ptr %virtual.slot16, align 8
  %call18 = call noundef i32 %virtual.callee17(ptr noundef nonnull align 8 dereferenceable(8) %base14)
  %add19 = add i32 %call13, %call18
  call void @"cw:Record:func(i32)void"(i32 noundef %add19)
  ret ptr %this
}

define noundef ptr @"cw:Both:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %base = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %watch = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  %base1 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %base2 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %vtable = load ptr, ptr %base2, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %base2)
  call void @"cw:Record:func(i32)void"(i32 noundef %call)
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Left:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Right:vtable", i32 0, i32 0, i32 2), ptr %base1, align 8
  %call3 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %watch)
  %call4 = call noundef ptr @"cw:Right:dtor():base"(ptr noundef returned %base)
  %call5 = call noundef ptr @"cw:Left:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Both:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Both:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %base = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %watch = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 2
  %base1 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %base2 = getelementptr inbounds nuw %struct.Both, ptr %this, i32 0, i32 1
  %vtable = load ptr, ptr %base2, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %base2)
  call void @"cw:Record:func(i32)void"(i32 noundef %call)
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Left:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Right:vtable", i32 0, i32 0, i32 2), ptr %base1, align 8
  %call3 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %watch)
  %call4 = call noundef ptr @"cw:Right:dtor():base"(ptr noundef returned %base)
  %call5 = call noundef ptr @"cw:Left:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define internal noundef i32 @"cw:Size:func(&copy Both)i32:thunk(-8,0)"(ptr noundef %0) {
entry:
  %this.adjusted = getelementptr inbounds i8, ptr %0, i64 -8
  %call = call noundef i32 @"cw:Size:func(&copy Both)i32"(ptr noundef nonnull align 8 dereferenceable(24) %this.adjusted)
  ret i32 %call
}
