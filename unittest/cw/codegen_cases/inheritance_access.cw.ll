%struct.Root = type { i32 }
%struct.Leaf = type { %struct.Middle.base, i8, i8 }
%struct.Middle.base = type <{ %struct.Root, i16 }>
%struct.Middle = type { %struct.Root, i16 }

define noundef nonnull align 4 dereferenceable(4) ptr @Select(ptr noundef nonnull align 4 dereferenceable(7) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @Pointer(ptr noundef %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @Null() {
entry:
  %.result = alloca ptr, align 8
  %value = alloca ptr, align 8
  store ptr null, ptr %value, align 8
  %0 = load ptr, ptr %value, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @Explicit(ptr noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Root, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef signext i8 @Hidden(ptr noundef nonnull align 4 dereferenceable(7) %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %Root = getelementptr inbounds nuw %struct.Leaf, ptr %0, i32 0, i32 1
  %1 = load i8, ptr %Root, align 2
  store i8 %1, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define noundef signext i16 @Nearest(ptr noundef nonnull align 4 dereferenceable(7) %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Middle, ptr %0, i32 0, i32 1
  %1 = load i16, ptr %value1, align 4
  store i16 %1, ptr %.result, align 2
  %2 = load i16, ptr %.result, align 2
  ret i16 %2
}
