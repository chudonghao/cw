define noundef nonnull align 4 ptr @Forward(ptr noundef nonnull align 4 %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @Assign(ptr noundef nonnull align 4 %source, ptr noundef nonnull align 4 %target) {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %call = call noundef nonnull align 4 ptr @Forward(ptr noundef nonnull align 4 %0)
  %1 = load ptr, ptr %target.addr, align 8
  %call1 = call noundef nonnull align 4 ptr @Forward(ptr noundef nonnull align 4 %1)
  ret void
}

define noundef i64 @Index(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %0, align 8
  %2 = load ptr, ptr %value.addr, align 8
  %3 = load i64, ptr %2, align 8
  %add = add i64 %1, %3
  %4 = load ptr, ptr %value.addr, align 8
  store i64 %add, ptr %4, align 8
  %5 = load ptr, ptr %value.addr, align 8
  %6 = load i64, ptr %5, align 8
  %7 = load ptr, ptr %value.addr, align 8
  %8 = load i64, ptr %7, align 8
  %sub = sub i64 %6, %8
  store i64 %sub, ptr %.result, align 8
  %9 = load i64, ptr %.result, align 8
  ret i64 %9
}

define void @Nested(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %value.addr = alloca ptr, align 8
  %values = alloca [2 x [0 x i32]], align 4
  %copied = alloca [0 x i32], align 4
  %temporary = alloca [0 x i32], align 4
  store ptr %value, ptr %value.addr, align 8
  %element = getelementptr inbounds nuw [2 x [0 x i32]], ptr %values, i64 0, i64 0
  %element1 = getelementptr inbounds nuw [2 x [0 x i32]], ptr %values, i64 0, i64 1
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i64 @Index(ptr noundef nonnull align 8 dereferenceable(8) %0)
  %element2 = getelementptr [2 x [0 x i32]], ptr %values, i64 0, i64 %call
  %1 = load ptr, ptr %value.addr, align 8
  %call3 = call noundef i64 @Index(ptr noundef nonnull align 8 dereferenceable(8) %1)
  %element4 = getelementptr [2 x [0 x i32]], ptr %values, i64 0, i64 %call3
  ret void
}

define void @Large(ptr noundef nonnull align 4 %source) {
entry:
  %source.addr = alloca ptr, align 8
  %copied = alloca [18446744073709551615 x [0 x i32]], align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  ret void
}
