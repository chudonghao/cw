%struct.Callable = type { i32 }

define noundef i32 @"()"(ptr noundef nonnull align 4 dereferenceable(4) %object, i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %object, ptr %object.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %1 = load ptr, ptr %object.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Callable, ptr %1, i32 0, i32 0
  store i32 %0, ptr %value1, align 4
  %2 = load ptr, ptr %object.addr, align 8
  %value2 = getelementptr inbounds nuw %struct.Callable, ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value2, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @"().1"(ptr noundef nonnull align 4 dereferenceable(4) %object, i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %object, ptr %object.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %object.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Callable, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  %2 = load i32, ptr %value.addr, align 4
  %add = add i32 %1, %2
  store i32 %add, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @Invoke(ptr noundef nonnull align 4 dereferenceable(8) %object, i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %object, ptr %object.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %object.addr, align 8
  %1 = load i32, ptr %value.addr, align 4
  %call = call noundef i32 @"()"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %1)
  %2 = load ptr, ptr %object.addr, align 8
  %3 = load i32, ptr %value.addr, align 4
  %call1 = call noundef i32 @"()"(ptr noundef nonnull align 4 dereferenceable(4) %2, i32 noundef %3)
  store i32 %call1, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @Read(ptr noundef nonnull align 4 dereferenceable(8) %object, i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %object, ptr %object.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %object.addr, align 8
  %1 = load i32, ptr %value.addr, align 4
  %call = call noundef i32 @"().1"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %1)
  store i32 %call, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Pointer(ptr noundef %object, i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %object, ptr %object.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %object.addr, align 8
  %1 = load i32, ptr %value.addr, align 4
  %call = call noundef i32 @"()"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %1)
  store i32 %call, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Temporary(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  %temporary = alloca %struct.Callable, align 4
  store i32 %value, ptr %value.addr, align 4
  call void @llvm.memset.p0.i64(ptr align 4 %temporary, i8 0, i64 4, i1 false)
  %0 = load i32, ptr %value.addr, align 4
  %call = call noundef i32 @"().1"(ptr noundef nonnull align 4 dereferenceable(4) %temporary, i32 noundef %0)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
