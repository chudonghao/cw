%struct.Factory = type { %struct.Plain, %struct.Maker, ptr }
%struct.Plain = type { ptr }
%struct.Maker = type { ptr }

@"cw:Factory:vtable" = constant { [7 x ptr], [4 x ptr] } { [7 x ptr] [ptr null, ptr null, ptr @"cw:Id:func(&copy Plain)i32", ptr @"cw:Item:func(&copy Factory)*Special:thunk(0,4)", ptr @"cw:Make:func(&copy Factory)*Special", ptr @"cw:Get:func(&copy Factory)&copy Special", ptr @"cw:Item:func(&copy Factory)*Special"], [4 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr @"cw:Make:func(&copy Factory)*Special:thunk(-8,4)", ptr @"cw:Get:func(&copy Factory)&copy Special:thunk(-8,4)"] }, align 8
@"cw:Plain:vtable" = external constant { [4 x ptr] }, align 8
@"cw:Maker:vtable" = external constant { [4 x ptr] }, align 8

declare noundef ptr @"cw:Plain:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Plain:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:Plain:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Plain:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Maker:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Maker:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:Maker:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Maker:dtor():base"(ptr noundef returned)

define noundef ptr @"cw:Make:func(&copy Factory)*Special"(ptr noundef nonnull align 8 dereferenceable(24) %this) {
entry:
  %.result = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %0 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.Factory, ptr %0, i32 0, i32 2
  %1 = load ptr, ptr %target, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 4 dereferenceable(8) ptr @"cw:Get:func(&copy Factory)&copy Special"(ptr noundef nonnull align 8 dereferenceable(24) %this) {
entry:
  %.result = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %0 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.Factory, ptr %0, i32 0, i32 2
  %1 = load ptr, ptr %target, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Item:func(&copy Factory)*Special"(ptr noundef nonnull align 8 dereferenceable(24) %this) {
entry:
  %.result = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %0 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.Factory, ptr %0, i32 0, i32 2
  %1 = load ptr, ptr %target, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Factory:ctor(*Special):complete"(ptr noundef returned %this, ptr noundef %target) {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %call = call noundef ptr @"cw:Plain:ctor():base"(ptr noundef returned %this)
  %base = getelementptr inbounds nuw %struct.Factory, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @"cw:Maker:ctor():base"(ptr noundef returned %base)
  %target2 = getelementptr inbounds nuw %struct.Factory, ptr %this, i32 0, i32 2
  %0 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %target2, align 8
  store ptr getelementptr inbounds inrange(-16, 40) ({ [7 x ptr], [4 x ptr] }, ptr @"cw:Factory:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [7 x ptr], [4 x ptr] }, ptr @"cw:Factory:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  ret ptr %this
}

define noundef ptr @"cw:Factory:ctor(*Special):base"(ptr noundef returned %this, ptr noundef %target) {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %call = call noundef ptr @"cw:Plain:ctor():base"(ptr noundef returned %this)
  %base = getelementptr inbounds nuw %struct.Factory, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @"cw:Maker:ctor():base"(ptr noundef returned %base)
  %target2 = getelementptr inbounds nuw %struct.Factory, ptr %this, i32 0, i32 2
  %0 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %target2, align 8
  store ptr getelementptr inbounds inrange(-16, 40) ({ [7 x ptr], [4 x ptr] }, ptr @"cw:Factory:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [7 x ptr], [4 x ptr] }, ptr @"cw:Factory:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  ret ptr %this
}

define noundef ptr @"cw:Factory:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 40) ({ [7 x ptr], [4 x ptr] }, ptr @"cw:Factory:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [7 x ptr], [4 x ptr] }, ptr @"cw:Factory:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %base = getelementptr inbounds nuw %struct.Factory, ptr %this, i32 0, i32 1
  %base1 = getelementptr inbounds nuw %struct.Factory, ptr %this, i32 0, i32 1
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr] }, ptr @"cw:Plain:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr] }, ptr @"cw:Maker:vtable", i32 0, i32 0, i32 2), ptr %base1, align 8
  %call = call noundef ptr @"cw:Maker:dtor():base"(ptr noundef returned %base)
  %call2 = call noundef ptr @"cw:Plain:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Factory:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 40) ({ [7 x ptr], [4 x ptr] }, ptr @"cw:Factory:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [7 x ptr], [4 x ptr] }, ptr @"cw:Factory:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  %base = getelementptr inbounds nuw %struct.Factory, ptr %this, i32 0, i32 1
  %base1 = getelementptr inbounds nuw %struct.Factory, ptr %this, i32 0, i32 1
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr] }, ptr @"cw:Plain:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr] }, ptr @"cw:Maker:vtable", i32 0, i32 0, i32 2), ptr %base1, align 8
  %call = call noundef ptr @"cw:Maker:dtor():base"(ptr noundef returned %base)
  %call2 = call noundef ptr @"cw:Plain:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:MakeThrough:func(&copy Maker)*Product"(ptr noundef nonnull align 8 dereferenceable(8) %maker) {
entry:
  %.result = alloca ptr, align 8
  %maker.addr = alloca ptr, align 8
  store ptr %maker, ptr %maker.addr, align 8
  %0 = load ptr, ptr %maker.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef ptr %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:GetThrough:func(&copy Maker)&copy Product"(ptr noundef nonnull align 8 dereferenceable(8) %maker) {
entry:
  %.result = alloca ptr, align 8
  %maker.addr = alloca ptr, align 8
  store ptr %maker, ptr %maker.addr, align 8
  %0 = load ptr, ptr %maker.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 1
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @"cw:MakeDirect:func(&copy Factory)*Special"(ptr noundef nonnull align 8 dereferenceable(24) %factory) {
entry:
  %.result = alloca ptr, align 8
  %factory.addr = alloca ptr, align 8
  store ptr %factory, ptr %factory.addr, align 8
  %0 = load ptr, ptr %factory.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 2
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef ptr %virtual.callee(ptr noundef nonnull align 8 dereferenceable(24) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

declare noundef i32 @"cw:Id:func(&copy Plain)i32"(ptr noundef nonnull align 8 dereferenceable(8))

define internal noundef ptr @"cw:Item:func(&copy Factory)*Special:thunk(0,4)"(ptr noundef %0) {
entry:
  %call = call noundef ptr @"cw:Item:func(&copy Factory)*Special"(ptr noundef nonnull align 8 dereferenceable(24) %0)
  %return.adjusted = getelementptr inbounds nuw i8, ptr %call, i64 4
  %1 = icmp eq ptr %call, null
  %return.nullable = select i1 %1, ptr null, ptr %return.adjusted
  ret ptr %return.nullable
}

define internal noundef ptr @"cw:Make:func(&copy Factory)*Special:thunk(-8,4)"(ptr noundef %0) {
entry:
  %this.adjusted = getelementptr inbounds i8, ptr %0, i64 -8
  %call = call noundef ptr @"cw:Make:func(&copy Factory)*Special"(ptr noundef nonnull align 8 dereferenceable(24) %this.adjusted)
  %return.adjusted = getelementptr inbounds nuw i8, ptr %call, i64 4
  %1 = icmp eq ptr %call, null
  %return.nullable = select i1 %1, ptr null, ptr %return.adjusted
  ret ptr %return.nullable
}

define internal noundef ptr @"cw:Get:func(&copy Factory)&copy Special:thunk(-8,4)"(ptr noundef %0) {
entry:
  %this.adjusted = getelementptr inbounds i8, ptr %0, i64 -8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @"cw:Get:func(&copy Factory)&copy Special"(ptr noundef nonnull align 8 dereferenceable(24) %this.adjusted)
  %return.adjusted = getelementptr inbounds nuw i8, ptr %call, i64 4
  ret ptr %return.adjusted
}
