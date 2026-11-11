%"struct.api::Pair" = type { %"struct.api::First", %"struct.api::Second.base" }
%"struct.api::First" = type { ptr }
%"struct.api::Second.base" = type <{ ptr, i32 }>

@"cw:Derived:vtable" = constant { [4 x ptr], [3 x ptr] } { [4 x ptr] [ptr null, ptr null, ptr @"cw:One:func(&copy Derived)i32", ptr @"cw:api::Two:func(&copy api::Pair)i32"], [3 x ptr] [ptr inttoptr (i64 -8 to ptr), ptr null, ptr @"cw:api::Two:func(&copy api::Pair)i32:thunk(-8,0)"] }, align 8
@"cw:api::Pair:vtable" = external constant { [4 x ptr], [3 x ptr] }, align 8

declare noundef ptr @"cw:api::First:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:api::First:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:api::Second:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:api::Second:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:api::Pair:ctor():complete"(ptr noundef returned)

declare noundef ptr @"cw:api::Pair:ctor():base"(ptr noundef returned)

declare noundef ptr @"cw:api::Pair:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:api::Pair:dtor():base"(ptr noundef returned)

define noundef i32 @"cw:One:func(&copy Derived)i32"(ptr noundef nonnull align 8 dereferenceable(20) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 1, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:api::Pair:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Derived:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Derived:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:api::Pair:ctor():base"(ptr noundef returned %this)
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Derived:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Derived:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Derived:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Derived:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:api::Pair:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field1 = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:api::Pair:vtable", i32 0, i32 1, i32 2), ptr %vtable.field1, align 8
  %call = call noundef ptr @"cw:api::Pair:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Derived:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:Derived:vtable", i32 0, i32 1, i32 2), ptr %vtable.field, align 8
  store ptr getelementptr inbounds inrange(-16, 16) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:api::Pair:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %vtable.field1 = getelementptr inbounds nuw i8, ptr %this, i64 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [4 x ptr], [3 x ptr] }, ptr @"cw:api::Pair:vtable", i32 0, i32 1, i32 2), ptr %vtable.field1, align 8
  %call = call noundef ptr @"cw:api::Pair:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef i32 @"cw:CallSecond:func(&copy api::Pair)i32"(ptr noundef nonnull align 8 dereferenceable(20) %pair) {
entry:
  %.result = alloca i32, align 4
  %pair.addr = alloca ptr, align 8
  store ptr %pair, ptr %pair.addr, align 8
  %0 = load ptr, ptr %pair.addr, align 8
  %base = getelementptr inbounds nuw %"struct.api::Pair", ptr %0, i32 0, i32 1
  %vtable = load ptr, ptr %base, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(12) %base)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

declare noundef i32 @"cw:api::Two:func(&copy api::Pair)i32"(ptr noundef nonnull align 8 dereferenceable(20))

define internal noundef i32 @"cw:api::Two:func(&copy api::Pair)i32:thunk(-8,0)"(ptr noundef %0) {
entry:
  %this.adjusted = getelementptr inbounds i8, ptr %0, i64 -8
  %call = call noundef i32 @"cw:api::Two:func(&copy api::Pair)i32"(ptr noundef nonnull align 8 dereferenceable(20) %this.adjusted)
  ret i32 %call
}
