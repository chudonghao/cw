define noundef i32 @Integers(i32 noundef %value, i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  %index.addr = alloca i64, align 8
  %values = alloca [2 x i32], align 4
  store i32 %value, ptr %value.addr, align 4
  store i64 %index, ptr %index.addr, align 8
  %element = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %element, align 4
  %element1 = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 1
  store i32 7, ptr %element1, align 4
  %1 = load i64, ptr %index.addr, align 8
  %element2 = getelementptr [2 x i32], ptr %values, i64 0, i64 %1
  %2 = load i32, ptr %element2, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef signext i16 @Nested(i16 noundef signext %value, i64 noundef %outer, i64 noundef %inner) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca i16, align 2
  %outer.addr = alloca i64, align 8
  %inner.addr = alloca i64, align 8
  %values = alloca [2 x [1 x i16]], align 2
  store i16 %value, ptr %value.addr, align 2
  store i64 %outer, ptr %outer.addr, align 8
  store i64 %inner, ptr %inner.addr, align 8
  %element = getelementptr inbounds nuw [2 x [1 x i16]], ptr %values, i64 0, i64 0
  %element1 = getelementptr inbounds nuw [1 x i16], ptr %element, i64 0, i64 0
  %0 = load i16, ptr %value.addr, align 2
  store i16 %0, ptr %element1, align 2
  %element2 = getelementptr inbounds nuw [2 x [1 x i16]], ptr %values, i64 0, i64 1
  %element3 = getelementptr inbounds nuw [1 x i16], ptr %element2, i64 0, i64 0
  store i16 5, ptr %element3, align 2
  %1 = load i64, ptr %outer.addr, align 8
  %element4 = getelementptr [2 x [1 x i16]], ptr %values, i64 0, i64 %1
  %2 = load i64, ptr %inner.addr, align 8
  %element5 = getelementptr [1 x i16], ptr %element4, i64 0, i64 %2
  %3 = load i16, ptr %element5, align 2
  store i16 %3, ptr %.result, align 2
  %4 = load i16, ptr %.result, align 2
  ret i16 %4
}

define noundef zeroext i1 @Booleans(i1 noundef zeroext %value, i64 noundef %index) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca i8, align 1
  %index.addr = alloca i64, align 8
  %values = alloca [2 x i8], align 1
  %storedv = zext i1 %value to i8
  store i8 %storedv, ptr %value.addr, align 1
  store i64 %index, ptr %index.addr, align 8
  %element = getelementptr inbounds nuw [2 x i8], ptr %values, i64 0, i64 0
  %0 = load i8, ptr %value.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %storedv1 = zext i1 %loadedv to i8
  store i8 %storedv1, ptr %element, align 1
  %element2 = getelementptr inbounds nuw [2 x i8], ptr %values, i64 0, i64 1
  store i8 0, ptr %element2, align 1
  %1 = load i64, ptr %index.addr, align 8
  %element3 = getelementptr [2 x i8], ptr %values, i64 0, i64 %1
  %2 = load i8, ptr %element3, align 1
  %loadedv4 = icmp ne i8 %2, 0
  %storedv5 = zext i1 %loadedv4 to i8
  store i8 %storedv5, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  %loadedv6 = icmp ne i8 %3, 0
  ret i1 %loadedv6
}

define noundef double @Floating(double noundef %value, i64 noundef %index) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca double, align 8
  %index.addr = alloca i64, align 8
  %values = alloca [2 x double], align 8
  store double %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %element = getelementptr inbounds nuw [2 x double], ptr %values, i64 0, i64 0
  %0 = load double, ptr %value.addr, align 8
  store double %0, ptr %element, align 8
  %element1 = getelementptr inbounds nuw [2 x double], ptr %values, i64 0, i64 1
  store double 2.500000e+00, ptr %element1, align 8
  %1 = load i64, ptr %index.addr, align 8
  %element2 = getelementptr [2 x double], ptr %values, i64 0, i64 %1
  %2 = load double, ptr %element2, align 8
  store double %2, ptr %.result, align 8
  %3 = load double, ptr %.result, align 8
  ret double %3
}

define noundef ptr @Pointers(ptr noundef %value, i64 noundef %index) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %values = alloca [2 x ptr], align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %element = getelementptr inbounds nuw [2 x ptr], ptr %values, i64 0, i64 0
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %element, align 8
  %element1 = getelementptr inbounds nuw [2 x ptr], ptr %values, i64 0, i64 1
  store ptr null, ptr %element1, align 8
  %1 = load i64, ptr %index.addr, align 8
  %element2 = getelementptr [2 x ptr], ptr %values, i64 0, i64 %1
  %2 = load ptr, ptr %element2, align 8
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}
