%struct.Value = type { i64 }
%struct.Empty = type { i8 }

define noundef i64 @"+"(i64 %left.coerce, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left = alloca %struct.Value, align 8
  %right.addr = alloca i64, align 8
  store i64 %left.coerce, ptr %left, align 8
  store i64 %right, ptr %right.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %left, i32 0, i32 0
  %0 = load i64, ptr %number, align 8
  %1 = load i64, ptr %right.addr, align 8
  %add = add i64 %0, %1
  %number1 = getelementptr inbounds nuw %struct.Value, ptr %left, i32 0, i32 0
  store i64 %add, ptr %number1, align 8
  %number2 = getelementptr inbounds nuw %struct.Value, ptr %left, i32 0, i32 0
  %2 = load i64, ptr %number2, align 8
  store i64 %2, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef i64 @Change(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  store i64 9, ptr %number, align 8
  store i64 0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @Capture(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.Value, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %0, i64 8, i1 false)
  %1 = load i64, ptr %argument, align 8
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i64 @Change(ptr noundef nonnull align 8 dereferenceable(8) %2)
  %call1 = call noundef i64 @"+"(i64 %1, i64 noundef %call)
  store i64 %call1, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef i64 @"()"(ptr noundef nonnull align 8 dereferenceable(8) %object, i64 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %object.addr = alloca ptr, align 8
  %value.addr = alloca i64, align 8
  store ptr %object, ptr %object.addr, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %object.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i64, ptr %number, align 8
  %2 = load i64, ptr %value.addr, align 8
  %add = add i64 %1, %2
  store i64 %add, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef nonnull align 8 dereferenceable(8) ptr @Locate(ptr noundef nonnull align 8 dereferenceable(8) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define noundef i64 @Invoke(ptr noundef nonnull align 8 dereferenceable(8) %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 8 dereferenceable(8) ptr @Locate(ptr noundef nonnull align 8 dereferenceable(8) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %value.addr, align 8
  %call1 = call noundef i64 @Change(ptr noundef nonnull align 8 dereferenceable(8) %2)
  %call2 = call noundef i64 @"()"(ptr noundef nonnull align 8 dereferenceable(8) %call, i64 noundef %call1)
  store i64 %call2, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define void @"!"() {
entry:
  %.result = alloca %struct.Empty, align 1
  %value = alloca %struct.Empty, align 1
  ret void
}

define void @MakeEmpty(ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca %struct.Empty, align 1
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  ret void
}

define void @EmptyResult(ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  call void @MakeEmpty(ptr noundef nonnull align 4 dereferenceable(4) %0)
  call void @"!"()
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
