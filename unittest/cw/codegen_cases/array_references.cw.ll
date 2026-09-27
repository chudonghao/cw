define noundef i32 @First(ptr noundef nonnull align 4 dereferenceable(8) %value, i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %index.addr, align 8
  %element = getelementptr [2 x i32], ptr %0, i64 0, i64 %1
  %2 = load i32, ptr %element, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef nonnull align 4 dereferenceable(8) ptr @Forward(ptr noundef nonnull align 4 dereferenceable(8) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 4 dereferenceable(8) ptr @ForwardMove(ptr noundef nonnull align 4 dereferenceable(8) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @ThroughPointer(ptr noundef nonnull align 4 dereferenceable(8) %value, i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %pointer = alloca ptr, align 8
  %bound = alloca ptr, align 8
  %callbacks = alloca [1 x ptr], align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %pointer, align 8
  %1 = load ptr, ptr %pointer, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @Forward(ptr noundef nonnull align 4 dereferenceable(8) %1)
  store ptr %call, ptr %bound, align 8
  %element = getelementptr inbounds nuw [1 x ptr], ptr %callbacks, i64 0, i64 0
  store ptr @First, ptr %element, align 8
  %2 = load i64, ptr %index.addr, align 8
  %element1 = getelementptr [1 x ptr], ptr %callbacks, i64 0, i64 %2
  %3 = load ptr, ptr %element1, align 8
  %4 = load ptr, ptr %bound, align 8
  %5 = load i64, ptr %index.addr, align 8
  %call2 = call noundef i32 %3(ptr noundef nonnull align 4 dereferenceable(8) %4, i64 noundef %5)
  %6 = load ptr, ptr %bound, align 8
  %call3 = call noundef nonnull align 4 dereferenceable(8) ptr @ForwardMove(ptr noundef nonnull align 4 dereferenceable(8) %6)
  %7 = load i64, ptr %index.addr, align 8
  %call4 = call noundef i32 @First(ptr noundef nonnull align 4 dereferenceable(8) %call3, i64 noundef %7)
  %add = add i32 %call2, %call4
  store i32 %add, ptr %.result, align 4
  %8 = load i32, ptr %.result, align 4
  ret i32 %8
}
