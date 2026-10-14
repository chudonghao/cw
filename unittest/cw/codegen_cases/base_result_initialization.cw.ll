%struct.Base = type { i8 }

define noundef ptr @"cw:Base:ctor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor(&move Base):complete"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:ctor(&move Base):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"cw:Make:func()Base"(ptr sret(%struct.Base) align 1 %.result) {
entry:
  %call = call noundef ptr @"cw:Base:ctor():complete"(ptr noundef returned %.result)
  ret void
}

define noundef ptr @"cw:Derived:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Base:ctor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  %temporary = alloca %struct.Base, align 1
  store i32 %value, ptr %value.addr, align 4
  call void @"cw:Make:func()Base"(ptr sret(%struct.Base) align 1 %temporary)
  %call = call noundef ptr @"cw:Base:ctor(&move Base):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %call1 = call noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %temporary)
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  %temporary = alloca %struct.Base, align 1
  store i32 %value, ptr %value.addr, align 4
  call void @"cw:Make:func()Base"(ptr sret(%struct.Base) align 1 %temporary)
  %call = call noundef ptr @"cw:Base:ctor(&move Base):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %call1 = call noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %temporary)
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor(bool):complete"(ptr noundef returned %this, i1 noundef zeroext %condition) {
entry:
  %condition.addr = alloca i8, align 1
  %temporary = alloca %struct.Base, align 1
  %storedv = zext i1 %condition to i8
  store i8 %storedv, ptr %condition.addr, align 1
  %0 = load i8, ptr %condition.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %call = call noundef ptr @"cw:Base:ctor():complete"(ptr noundef returned %temporary)
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @"cw:Make:func()Base"(ptr sret(%struct.Base) align 1 %temporary)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %call1 = call noundef ptr @"cw:Base:ctor(&move Base):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %call2 = call noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %temporary)
  ret ptr %this
}

define noundef ptr @"cw:Derived:ctor(bool):base"(ptr noundef returned %this, i1 noundef zeroext %condition) {
entry:
  %condition.addr = alloca i8, align 1
  %temporary = alloca %struct.Base, align 1
  %storedv = zext i1 %condition to i8
  store i8 %storedv, ptr %condition.addr, align 1
  %0 = load i8, ptr %condition.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %call = call noundef ptr @"cw:Base:ctor():complete"(ptr noundef returned %temporary)
  br label %cond.end

cond.false:                                       ; preds = %entry
  call void @"cw:Make:func()Base"(ptr sret(%struct.Base) align 1 %temporary)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %call1 = call noundef ptr @"cw:Base:ctor(&move Base):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %call2 = call noundef ptr @"cw:Base:dtor():complete"(ptr noundef returned %temporary)
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Derived:dtor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Base:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}
