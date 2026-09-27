@.str = private constant [3 x i8] c"abc", align 1

define noundef nonnull align 1 dereferenceable(3) ptr @Borrow() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @Pointer() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef zeroext i8 @Read(ptr noundef nonnull align 1 dereferenceable(3) %value, i64 noundef %index) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %index.addr, align 8
  %element = getelementptr [3 x i8], ptr %0, i64 0, i64 %1
  %2 = load i8, ptr %element, align 1
  store i8 %2, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  ret i8 %3
}

define noundef zeroext i8 @Use(i64 noundef %index) {
entry:
  %.result = alloca i8, align 1
  %index.addr = alloca i64, align 8
  %callback = alloca ptr, align 8
  store i64 %index, ptr %index.addr, align 8
  store ptr @Read, ptr %callback, align 8
  %call = call noundef nonnull align 1 dereferenceable(3) ptr @Borrow()
  %0 = load i64, ptr %index.addr, align 8
  %call1 = call noundef zeroext i8 @Read(ptr noundef nonnull align 1 dereferenceable(3) %call, i64 noundef %0)
  %1 = load ptr, ptr %callback, align 8
  %call2 = call noundef ptr @Pointer()
  %2 = load i64, ptr %index.addr, align 8
  %call3 = call noundef zeroext i8 %1(ptr noundef nonnull align 1 dereferenceable(3) %call2, i64 noundef %2)
  %add = add i8 %call1, %call3
  %3 = load i64, ptr %index.addr, align 8
  %call4 = call noundef zeroext i8 @Read(ptr noundef nonnull align 1 dereferenceable(3) @.str, i64 noundef %3)
  %add5 = add i8 %add, %call4
  store i8 %add5, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  ret i8 %4
}
