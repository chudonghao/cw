%struct.Item = type { i32 }

define noundef ptr @Item.ctor(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @Item.ctor.1(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %other.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @Item.ctor.2(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %other.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @Item.ctor.3(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @Item.ctor(ptr noundef returned %this, i32 noundef 7)
  ret ptr %this
}

define noundef ptr @Item.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @Construct() {
entry:
  %first = alloca %struct.Item, align 4
  %copied = alloca %struct.Item, align 4
  %moved = alloca %struct.Item, align 4
  %temporary = alloca %struct.Item, align 4
  %call = call noundef ptr @Item.ctor.3(ptr noundef returned %first)
  %call1 = call noundef ptr @Item.ctor.1(ptr noundef returned %copied, ptr noundef nonnull align 4 dereferenceable(4) %first)
  %call2 = call noundef ptr @Item.ctor.2(ptr noundef returned %moved, ptr noundef nonnull align 4 dereferenceable(4) %first)
  %call3 = call noundef ptr @Item.ctor(ptr noundef returned %temporary, i32 noundef 9)
  %call4 = call noundef ptr @Item.dtor(ptr noundef returned %temporary)
  %call5 = call noundef ptr @Item.dtor(ptr noundef returned %moved)
  %call6 = call noundef ptr @Item.dtor(ptr noundef returned %copied)
  %call7 = call noundef ptr @Item.dtor(ptr noundef returned %first)
  ret void
}
