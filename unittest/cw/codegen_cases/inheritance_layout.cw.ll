%struct.Leaf = type { %struct.Middle.base, i8, [2 x i8] }
%struct.Middle.base = type <{ %struct.Root, i8 }>
%struct.Root = type { i32 }
%struct.Middle = type { %struct.Root, i8 }
%struct.Box = type { i8, [3 x i8], %struct.Leaf }

define noundef i32 @Fields(i32 noundef %number, i8 noundef zeroext %tag, i8 noundef zeroext %extra) {
entry:
  %.result = alloca i32, align 4
  %number.addr = alloca i32, align 4
  %tag.addr = alloca i8, align 1
  %extra.addr = alloca i8, align 1
  %value = alloca %struct.Leaf, align 4
  store i32 %number, ptr %number.addr, align 4
  store i8 %tag, ptr %tag.addr, align 1
  store i8 %extra, ptr %extra.addr, align 1
  %number1 = getelementptr inbounds nuw %struct.Root, ptr %value, i32 0, i32 0
  %0 = load i32, ptr %number.addr, align 4
  store i32 %0, ptr %number1, align 4
  %tag2 = getelementptr inbounds nuw %struct.Middle, ptr %value, i32 0, i32 1
  %1 = load i8, ptr %tag.addr, align 1
  store i8 %1, ptr %tag2, align 4
  %extra3 = getelementptr inbounds nuw %struct.Leaf, ptr %value, i32 0, i32 1
  %2 = load i8, ptr %extra.addr, align 1
  store i8 %2, ptr %extra3, align 1
  %number4 = getelementptr inbounds nuw %struct.Root, ptr %value, i32 0, i32 0
  %3 = load i32, ptr %number4, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef ptr @Extra(ptr noundef nonnull align 4 dereferenceable(6) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %extra = getelementptr inbounds nuw %struct.Leaf, ptr %0, i32 0, i32 1
  store ptr %extra, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @Element(ptr noundef nonnull align 4 dereferenceable(16) %values, i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %values.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %values, ptr %values.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %values.addr, align 8
  %1 = load i64, ptr %index.addr, align 8
  %element = getelementptr [2 x %struct.Leaf], ptr %0, i64 0, i64 %1
  %number = getelementptr inbounds nuw %struct.Root, ptr %element, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef ptr @Nested(ptr noundef nonnull align 4 dereferenceable(12) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Box, ptr %0, i32 0, i32 2
  %extra = getelementptr inbounds nuw %struct.Leaf, ptr %value1, i32 0, i32 1
  store ptr %extra, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}
