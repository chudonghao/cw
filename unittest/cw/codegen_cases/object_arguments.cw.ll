%struct.Token = type { i8 }
%struct.Box = type { i8 }

define noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Token:ctor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Token:ctor(&copy Token):complete"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Token:ctor(&copy Token):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Token:ctor(&move Token):complete"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Token:ctor(&move Token):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
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

define void @"cw:Consume:func(Token,i32)void"(ptr noundef %value, i32 noundef %next) {
entry:
  %next.addr = alloca i32, align 4
  store i32 %next, ptr %next.addr, align 4
  ret void
}

define noundef i32 @"cw:Next:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 3, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @"cw:Select:func(*func(Token,i32)void)*func(Token,i32)void"(ptr noundef %operation) {
entry:
  %.result = alloca ptr, align 8
  %operation.addr = alloca ptr, align 8
  store ptr %operation, ptr %operation.addr, align 8
  %0 = load ptr, ptr %operation.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @"cw:Arguments:func()void"() {
entry:
  %source = alloca %struct.Token, align 1
  %argument = alloca %struct.Token, align 1
  %argument4 = alloca %struct.Token, align 1
  %operation = alloca ptr, align 8
  %argument9 = alloca %struct.Token, align 1
  %call = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %source)
  %call1 = call noundef ptr @"cw:Token:ctor(&copy Token):complete"(ptr noundef returned %argument, ptr noundef nonnull align 1 dereferenceable(1) %source)
  %call2 = call noundef i32 @"cw:Next:func()i32"()
  call void @"cw:Consume:func(Token,i32)void"(ptr noundef %argument, i32 noundef %call2)
  %call3 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %argument)
  %call5 = call noundef ptr @"cw:Token:ctor(&move Token):complete"(ptr noundef returned %argument4, ptr noundef nonnull align 1 dereferenceable(1) %source)
  %call6 = call noundef i32 @"cw:Next:func()i32"()
  call void @"cw:Consume:func(Token,i32)void"(ptr noundef %argument4, i32 noundef %call6)
  %call7 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %argument4)
  store ptr @"cw:Consume:func(Token,i32)void", ptr %operation, align 8
  %0 = load ptr, ptr %operation, align 8
  %call8 = call noundef ptr @"cw:Select:func(*func(Token,i32)void)*func(Token,i32)void"(ptr noundef %0)
  %call10 = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %argument9)
  %call11 = call noundef i32 @"cw:Next:func()i32"()
  call void %call8(ptr noundef %argument9, i32 noundef %call11)
  %call12 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %argument9)
  %call13 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %source)
  ret void
}

define noundef ptr @"cw:Box:ctor(Token,i32):complete"(ptr noundef returned %this, ptr noundef %value, i32 noundef %next) {
entry:
  %next.addr = alloca i32, align 4
  store i32 %next, ptr %next.addr, align 4
  ret ptr %this
}

define noundef ptr @"cw:Box:ctor(Token,i32):base"(ptr noundef returned %this, ptr noundef %value, i32 noundef %next) {
entry:
  %next.addr = alloca i32, align 4
  store i32 %next, ptr %next.addr, align 4
  ret ptr %this
}

define noundef ptr @"cw:Box:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Box:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"cw:Pack:func()void"() {
entry:
  %box = alloca %struct.Box, align 1
  %argument = alloca %struct.Token, align 1
  %call = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %argument)
  %call1 = call noundef i32 @"cw:Next:func()i32"()
  %call2 = call noundef ptr @"cw:Box:ctor(Token,i32):complete"(ptr noundef returned %box, ptr noundef %argument, i32 noundef %call1)
  %call3 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %argument)
  %call4 = call noundef ptr @"cw:Box:dtor():complete"(ptr noundef returned %box)
  ret void
}
