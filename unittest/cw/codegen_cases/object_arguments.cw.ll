%struct.Token = type { i8 }
%struct.Box = type { i8 }

define noundef ptr @Token.ctor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Token.ctor.1(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  ret ptr %this
}

define noundef ptr @Token.ctor.2(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  ret ptr %this
}

define noundef ptr @Token.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @Consume(ptr noundef %value, i32 noundef %next) {
entry:
  %next.addr = alloca i32, align 4
  store i32 %next, ptr %next.addr, align 4
  ret void
}

define noundef i32 @Next() {
entry:
  %.result = alloca i32, align 4
  store i32 3, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @Select(ptr noundef %operation) {
entry:
  %.result = alloca ptr, align 8
  %operation.addr = alloca ptr, align 8
  store ptr %operation, ptr %operation.addr, align 8
  %0 = load ptr, ptr %operation.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @Arguments() {
entry:
  %source = alloca %struct.Token, align 1
  %argument = alloca %struct.Token, align 1
  %argument4 = alloca %struct.Token, align 1
  %operation = alloca ptr, align 8
  %argument9 = alloca %struct.Token, align 1
  %call = call noundef ptr @Token.ctor(ptr noundef returned %source)
  %call1 = call noundef ptr @Token.ctor.1(ptr noundef returned %argument, ptr noundef nonnull align 1 dereferenceable(1) %source)
  %call2 = call noundef i32 @Next()
  call void @Consume(ptr noundef %argument, i32 noundef %call2)
  %call3 = call noundef ptr @Token.dtor(ptr noundef returned %argument)
  %call5 = call noundef ptr @Token.ctor.2(ptr noundef returned %argument4, ptr noundef nonnull align 1 dereferenceable(1) %source)
  %call6 = call noundef i32 @Next()
  call void @Consume(ptr noundef %argument4, i32 noundef %call6)
  %call7 = call noundef ptr @Token.dtor(ptr noundef returned %argument4)
  store ptr @Consume, ptr %operation, align 8
  %0 = load ptr, ptr %operation, align 8
  %call8 = call noundef ptr @Select(ptr noundef %0)
  %call10 = call noundef ptr @Token.ctor(ptr noundef returned %argument9)
  %call11 = call noundef i32 @Next()
  call void %call8(ptr noundef %argument9, i32 noundef %call11)
  %call12 = call noundef ptr @Token.dtor(ptr noundef returned %argument9)
  %call13 = call noundef ptr @Token.dtor(ptr noundef returned %source)
  ret void
}

define noundef ptr @Box.ctor(ptr noundef returned %this, ptr noundef %value, i32 noundef %next) {
entry:
  %next.addr = alloca i32, align 4
  store i32 %next, ptr %next.addr, align 4
  ret ptr %this
}

define noundef ptr @Box.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @Pack() {
entry:
  %box = alloca %struct.Box, align 1
  %argument = alloca %struct.Token, align 1
  %call = call noundef ptr @Token.ctor(ptr noundef returned %argument)
  %call1 = call noundef i32 @Next()
  %call2 = call noundef ptr @Box.ctor(ptr noundef returned %box, ptr noundef %argument, i32 noundef %call1)
  %call3 = call noundef ptr @Token.dtor(ptr noundef returned %argument)
  %call4 = call noundef ptr @Box.dtor(ptr noundef returned %box)
  ret void
}
