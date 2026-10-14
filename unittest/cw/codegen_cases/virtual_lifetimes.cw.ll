%struct.Derived = type { %struct.Base, %struct.Watch, i32 }
%struct.Base = type { ptr }
%struct.Watch = type { ptr }

@__dso_handle = external hidden global i8
@"cw:trace:var" = global i64 0, align 8
@"cw:global:var" = global %struct.Derived zeroinitializer, align 8
@"cw:Base:vtable" = constant [3 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Base)i32"], align 8
@"cw:Derived:vtable" = constant [3 x ptr] [ptr null, ptr null, ptr @"cw:Read:func(&copy Derived)i32"], align 8
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @"cw:global_init", ptr null }]

; Function Attrs: nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) #0

define noundef i32 @"cw:Read:func(&copy Base)i32"(ptr noundef nonnull align 8 dereferenceable(8) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 1, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %object) {
entry:
  %object.addr = alloca ptr, align 8
  store ptr %object, ptr %object.addr, align 8
  %0 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %0, 10
  %1 = load ptr, ptr %object.addr, align 8
  %vtable = load ptr, ptr %1, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef i32 %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %1)
  %conv = sext i32 %call to i64
  %add = add i64 %mul, %conv
  store i64 %add, ptr @"cw:trace:var", align 8
  ret void
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
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  ret ptr %this
}

define noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %this, ptr noundef %target) {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %target1 = getelementptr inbounds nuw %struct.Watch, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %target1, align 8
  ret ptr %this
}

define noundef ptr @"cw:Watch:ctor(*const Base):base"(ptr noundef returned %this, ptr noundef %target) {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %target1 = getelementptr inbounds nuw %struct.Watch, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %target1, align 8
  ret ptr %this
}

define noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %this) {
entry:
  %target = getelementptr inbounds nuw %struct.Watch, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %target, align 8
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %0)
  ret ptr %this
}

define noundef ptr @"cw:Watch:dtor():base"(ptr noundef returned %this) {
entry:
  %target = getelementptr inbounds nuw %struct.Watch, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %target, align 8
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %0)
  ret ptr %this
}

define noundef i32 @"cw:Complete:func(&copy Watch)i32"(ptr noundef nonnull align 8 dereferenceable(8) %watch) {
entry:
  %.result = alloca i32, align 4
  %watch.addr = alloca ptr, align 8
  store ptr %watch, ptr %watch.addr, align 8
  store i32 0, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:Read:func(&copy Derived)i32"(ptr noundef nonnull align 8 dereferenceable(20) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 2, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Derived:ctor(bool):complete"(ptr noundef returned %this, i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %local = alloca %struct.Watch, align 8
  %temporary = alloca %struct.Watch, align 8
  %local7 = alloca %struct.Watch, align 8
  %temporary10 = alloca %struct.Watch, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %call = call noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this)
  %watch = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %watch, ptr noundef %this)
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call2 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %local, ptr noundef %this)
  %value = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 2
  %call3 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %temporary, ptr noundef %this)
  %call4 = call noundef i32 @"cw:Complete:func(&copy Watch)i32"(ptr noundef nonnull align 8 dereferenceable(8) %temporary)
  store i32 %call4, ptr %value, align 8
  %call5 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %temporary)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %call6 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %local)
  br label %if.end

if.else:                                          ; preds = %entry
  %call8 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %local7, ptr noundef %this)
  %value9 = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 2
  %call11 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %temporary10, ptr noundef %this)
  %call12 = call noundef i32 @"cw:Complete:func(&copy Watch)i32"(ptr noundef nonnull align 8 dereferenceable(8) %temporary10)
  %add = add i32 %call12, 1
  store i32 %add, ptr %value9, align 8
  %call13 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %temporary10)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %call14 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %local7)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor(bool):base"(ptr noundef returned %this, i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %local = alloca %struct.Watch, align 8
  %temporary = alloca %struct.Watch, align 8
  %local7 = alloca %struct.Watch, align 8
  %temporary10 = alloca %struct.Watch, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %call = call noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this)
  %watch = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %watch, ptr noundef %this)
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call2 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %local, ptr noundef %this)
  %value = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 2
  %call3 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %temporary, ptr noundef %this)
  %call4 = call noundef i32 @"cw:Complete:func(&copy Watch)i32"(ptr noundef nonnull align 8 dereferenceable(8) %temporary)
  store i32 %call4, ptr %value, align 8
  %call5 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %temporary)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %call6 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %local)
  br label %if.end

if.else:                                          ; preds = %entry
  %call8 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %local7, ptr noundef %this)
  %value9 = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 2
  %call11 = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %temporary10, ptr noundef %this)
  %call12 = call noundef i32 @"cw:Complete:func(&copy Watch)i32"(ptr noundef nonnull align 8 dereferenceable(8) %temporary10)
  %add = add i32 %call12, 1
  store i32 %add, ptr %value9, align 8
  %call13 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %temporary10)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %call14 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %local7)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Derived:ctor(bool):complete"(ptr noundef returned %this, i1 noundef zeroext true)
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Derived:ctor(bool):base"(ptr noundef returned %this, i1 noundef zeroext true)
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %this) {
entry:
  %local = alloca %struct.Watch, align 8
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  %watch = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 1
  %call = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %local, ptr noundef %this)
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %value = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 2
  %0 = load i32, ptr %value, align 8
  %cmp = icmp eq i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %call1 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %local)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call2 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %watch)
  %call3 = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  br label %return

if.end:                                           ; preds = %entry
  %call4 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %local)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call5 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %watch)
  %call6 = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  br label %return

return:                                           ; preds = %if.end, %if.then
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():base"(ptr noundef returned %this) {
entry:
  %local = alloca %struct.Watch, align 8
  store ptr getelementptr ([3 x ptr], ptr @"cw:Derived:vtable", i64 0, i64 2), ptr %this, align 8
  %watch = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 1
  %call = call noundef ptr @"cw:Watch:ctor(*const Base):complete"(ptr noundef returned %local, ptr noundef %this)
  call void @"cw:Record:func(&copy Base)void"(ptr noundef nonnull align 8 dereferenceable(8) %this)
  %value = getelementptr inbounds nuw %struct.Derived, ptr %this, i32 0, i32 2
  %0 = load i32, ptr %value, align 8
  %cmp = icmp eq i32 %0, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %call1 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %local)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call2 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %watch)
  %call3 = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  br label %return

if.end:                                           ; preds = %entry
  %call4 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %local)
  store ptr getelementptr ([3 x ptr], ptr @"cw:Base:vtable", i64 0, i64 2), ptr %this, align 8
  %call5 = call noundef ptr @"cw:Watch:dtor():complete"(ptr noundef returned %watch)
  %call6 = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  br label %return

return:                                           ; preds = %if.end, %if.then
  ret ptr %this
}

define noundef i64 @"cw:ReadTrace:func()i64"() {
entry:
  %.result = alloca i64, align 8
  %0 = load i64, ptr @"cw:trace:var", align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @"cw:Entry:func(bool)i64"(i1 noundef zeroext %flag) {
entry:
  %.result = alloca i64, align 8
  %flag.addr = alloca i8, align 1
  %value = alloca %struct.Derived, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i64 0, ptr @"cw:trace:var", align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %call = call noundef ptr @"cw:Derived:ctor(bool):complete"(ptr noundef returned %value, i1 noundef zeroext %loadedv)
  %call1 = call noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %value)
  %1 = load i64, ptr @"cw:trace:var", align 8
  store i64 %1, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

define noundef i64 @"cw:Delegate:func()i64"() {
entry:
  %.result = alloca i64, align 8
  %value = alloca %struct.Derived, align 8
  store i64 0, ptr @"cw:trace:var", align 8
  %call = call noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %value)
  %call1 = call noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %value)
  %0 = load i64, ptr @"cw:trace:var", align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define internal void @"cw:global_var_init"() {
entry:
  store i64 0, ptr @"cw:trace:var", align 8
  ret void
}

define internal void @"cw:global_var_init.1"() {
entry:
  %call = call noundef ptr @"cw:Derived:ctor(bool):complete"(ptr noundef returned @"cw:global:var", i1 noundef zeroext true)
  %0 = call i32 @__cxa_atexit(ptr @"cw:Derived:dtor():complete", ptr @"cw:global:var", ptr @__dso_handle) #0
  ret void
}

define internal void @"cw:global_init"() {
entry:
  call void @"cw:global_var_init"()
  call void @"cw:global_var_init.1"()
  ret void
}

attributes #0 = { nounwind }
