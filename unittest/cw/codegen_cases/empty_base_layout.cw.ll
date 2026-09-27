%struct.Aligned = type { [0 x i32], [4 x i8] }
%struct.Child = type { %struct.Aligned.base, i8, [2 x i8] }
%struct.Aligned.base = type <{ [0 x i32], i8 }>
%struct.Distinct = type { i8, %struct.Member, i8 }
%struct.Member = type { %struct.Empty }
%struct.Empty = type { i8 }

define noundef ptr @Anchor.ctor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Anchor.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Aligned.ctor(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @Anchor.ctor(ptr noundef returned %this)
  %zero = getelementptr inbounds nuw %struct.Aligned, ptr %this, i32 0, i32 0
  ret ptr %this
}

define noundef ptr @Aligned.dtor(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @Anchor.dtor(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @Child.ctor(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @Aligned.ctor(ptr noundef returned %this)
  %value = getelementptr inbounds nuw %struct.Child, ptr %this, i32 0, i32 1
  store i8 7, ptr %value, align 1
  ret ptr %this
}

define noundef ptr @Child.dtor(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @Aligned.dtor(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @Base(ptr noundef nonnull align 1 dereferenceable(3) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @Nested(ptr noundef nonnull align 1 dereferenceable(3) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %member = getelementptr inbounds nuw %struct.Distinct, ptr %0, i32 0, i32 1
  %empty = getelementptr inbounds nuw %struct.Member, ptr %member, i32 0, i32 0
  store ptr %empty, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @Last(ptr noundef nonnull align 1 dereferenceable(3) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Distinct, ptr %0, i32 0, i32 2
  store ptr %value1, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @Make(ptr sret(%struct.Child) align 4 %.result) {
entry:
  %call = call noundef ptr @Child.ctor(ptr noundef returned %.result)
  ret void
}
