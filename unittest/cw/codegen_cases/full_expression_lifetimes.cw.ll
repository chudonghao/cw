%struct.Holder = type { i8 }
%struct.Token = type { i8 }

define noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Token:ctor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Token:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Holder:ctor(&copy Token):complete"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Holder:ctor(&copy Token):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Holder:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Holder:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"cw:Make:func(&copy Token)Holder"(ptr sret(%struct.Holder) align 1 %.result, ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef ptr @"cw:Holder:ctor(&copy Token):complete"(ptr noundef returned %.result, ptr noundef nonnull align 1 dereferenceable(1) %0)
  ret void
}

define void @"cw:Boundaries:func()void"() {
entry:
  %first = alloca %struct.Holder, align 1
  %second = alloca %struct.Holder, align 1
  %temporary = alloca %struct.Token, align 1
  %temporary3 = alloca %struct.Token, align 1
  %block = alloca %struct.Holder, align 1
  %inner = alloca %struct.Token, align 1
  %temporary7 = alloca %struct.Token, align 1
  %call = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %temporary)
  %call1 = call noundef ptr @"cw:Holder:ctor(&copy Token):complete"(ptr noundef returned %first, ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %call2 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %temporary)
  %call4 = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %temporary3)
  call void @"cw:Make:func(&copy Token)Holder"(ptr sret(%struct.Holder) align 1 %second, ptr noundef nonnull align 1 dereferenceable(1) %temporary3)
  %call5 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %temporary3)
  %call6 = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %inner)
  %call8 = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %temporary7)
  %call9 = call noundef ptr @"cw:Holder:ctor(&copy Token):complete"(ptr noundef returned %block, ptr noundef nonnull align 1 dereferenceable(1) %temporary7)
  %call10 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %temporary7)
  %call11 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %inner)
  %call12 = call noundef ptr @"cw:Holder:dtor():complete"(ptr noundef returned %block)
  %call13 = call noundef ptr @"cw:Holder:dtor():complete"(ptr noundef returned %second)
  %call14 = call noundef ptr @"cw:Holder:dtor():complete"(ptr noundef returned %first)
  ret void
}

define void @"cw:Returning:func()Holder"(ptr sret(%struct.Holder) align 1 %.result) {
entry:
  %local = alloca %struct.Token, align 1
  %temporary = alloca %struct.Token, align 1
  %call = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %local)
  %call1 = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %temporary)
  %call2 = call noundef ptr @"cw:Holder:ctor(&copy Token):complete"(ptr noundef returned %.result, ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %call3 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %temporary)
  %call4 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %local)
  ret void
}
