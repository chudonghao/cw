%struct.Counter = type { %struct.Base, i32 }
%struct.Base = type { ptr }

@"cw:Base:vtable" = constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Base)i32"] }, align 8
@"cw:Counter:vtable" = constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Counter)i32"] }, align 8
@"cw:Probe:vtable" = constant { [3 x ptr] } { [3 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Probe)i32"] }, align 8

define noundef i32 @"cw:Read:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 1, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Base:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Base:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Base:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Base:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Base:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef i32 @"cw:Read:func(&copy Counter)i32"(ptr noundef nonnull align 8 dereferenceable(12) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 2, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Counter:ctor(i32,bool):complete"(ptr noundef returned %this, i32 noundef %start, i1 noundef zeroext %skip_first) {
entry:
  %start.addr = alloca i32, align 4
  %skip_first.addr = alloca i8, align 1
  %first = alloca i32, align 4
  store i32 %start, ptr %start.addr, align 4
  %storedv = zext i1 %skip_first to i8
  store i8 %storedv, ptr %skip_first.addr, align 1
  %0 = load i32, ptr %start.addr, align 4
  %add = add i32 %0, 1
  store i32 %add, ptr %first, align 4
  %1 = load i8, ptr %skip_first.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %2 = load i32, ptr %first, align 4
  %call = call noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef %2)
  br label %if.end

if.else:                                          ; preds = %entry
  %3 = load i32, ptr %start.addr, align 4
  %call1 = call noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef %3)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %limit = getelementptr inbounds nuw %struct.Counter, ptr %this, i32 0, i32 1
  %4 = load i32, ptr %first, align 4
  %add2 = add i32 %4, 10
  store i32 %add2, ptr %limit, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Counter:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Counter:ctor(i32,bool):base"(ptr noundef returned %this, i32 noundef %start, i1 noundef zeroext %skip_first) {
entry:
  %start.addr = alloca i32, align 4
  %skip_first.addr = alloca i8, align 1
  %first = alloca i32, align 4
  store i32 %start, ptr %start.addr, align 4
  %storedv = zext i1 %skip_first to i8
  store i8 %storedv, ptr %skip_first.addr, align 1
  %0 = load i32, ptr %start.addr, align 4
  %add = add i32 %0, 1
  store i32 %add, ptr %first, align 4
  %1 = load i8, ptr %skip_first.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %2 = load i32, ptr %first, align 4
  %call = call noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef %2)
  br label %if.end

if.else:                                          ; preds = %entry
  %3 = load i32, ptr %start.addr, align 4
  %call1 = call noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef %3)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %limit = getelementptr inbounds nuw %struct.Counter, ptr %this, i32 0, i32 1
  %4 = load i32, ptr %first, align 4
  %add2 = add i32 %4, 10
  store i32 %add2, ptr %limit, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Counter:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Counter:ctor(bool):complete"(ptr noundef returned %this, i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = call noundef ptr @"cw:Counter:ctor(i32,bool):complete"(ptr noundef returned %this, i32 noundef 3, i1 noundef zeroext true)
  br label %if.end

if.else:                                          ; preds = %entry
  %call1 = call noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef 3)
  %limit = getelementptr inbounds nuw %struct.Counter, ptr %this, i32 0, i32 1
  store i32 4, ptr %limit, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Counter:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret ptr %this
}

define noundef ptr @"cw:Counter:ctor(bool):base"(ptr noundef returned %this, i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = call noundef ptr @"cw:Counter:ctor(i32,bool):base"(ptr noundef returned %this, i32 noundef 3, i1 noundef zeroext true)
  br label %if.end

if.else:                                          ; preds = %entry
  %call1 = call noundef ptr @"cw:Base:ctor(i32):base"(ptr noundef returned %this, i32 noundef 3)
  %limit = getelementptr inbounds nuw %struct.Counter, ptr %this, i32 0, i32 1
  store i32 4, ptr %limit, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Counter:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret ptr %this
}

define noundef ptr @"cw:Counter:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Counter:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Base:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Counter:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Counter:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Base:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef i32 @"cw:Read:func(&copy Probe)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 5, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Probe:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Probe:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Probe:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Probe:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Probe:ctor(bool):complete"(ptr noundef returned %this, i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %before = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Probe:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = call noundef ptr @"cw:Probe:ctor(i32):complete"(ptr noundef returned %this, i32 noundef 1)
  br label %if.end

if.else:                                          ; preds = %entry
  %vtable = load ptr, ptr %this, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call1 = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %this)
  store i32 %call1, ptr %before, align 4
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret ptr %this
}

define noundef ptr @"cw:Probe:ctor(bool):base"(ptr noundef returned %this, i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %before = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Probe:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = call noundef ptr @"cw:Probe:ctor(i32):base"(ptr noundef returned %this, i32 noundef 1)
  br label %if.end

if.else:                                          ; preds = %entry
  %vtable = load ptr, ptr %this, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call1 = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %this)
  store i32 %call1, ptr %before, align 4
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret ptr %this
}

define noundef ptr @"cw:Probe:dtor():complete"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Probe:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @"cw:Probe:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr inbounds inrange(-16, 8) ({ [3 x ptr] }, ptr @"cw:Probe:vtable", i32 0, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}
