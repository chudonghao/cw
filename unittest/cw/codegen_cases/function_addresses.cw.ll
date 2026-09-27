define noundef i32 @Select(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef double @Select.1(double noundef %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  store double %0, ptr %.result, align 8
  %1 = load double, ptr %.result, align 8
  ret double %1
}

define noundef ptr @Get() {
entry:
  %.result = alloca ptr, align 8
  store ptr @Select.1, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef double @Invoke(double noundef %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca double, align 8
  %callback = alloca ptr, align 8
  store double %value, ptr %value.addr, align 8
  store ptr @Select.1, ptr %callback, align 8
  %0 = load ptr, ptr %callback, align 8
  %1 = load double, ptr %value.addr, align 8
  %call = call noundef double %0(double noundef %1)
  store double %call, ptr %.result, align 8
  %2 = load double, ptr %.result, align 8
  ret double %2
}

define noundef double @Apply(ptr noundef %callback, double noundef %value) {
entry:
  %.result = alloca double, align 8
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca double, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load double, ptr %value.addr, align 8
  %call = call noundef double %0(double noundef %1)
  store double %call, ptr %.result, align 8
  %2 = load double, ptr %.result, align 8
  ret double %2
}

define noundef double @Pass() {
entry:
  %.result = alloca double, align 8
  %call = call noundef double @Apply(ptr noundef @Select.1, double noundef 2.500000e+00)
  store double %call, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef ptr @Forward() {
entry:
  %.result = alloca ptr, align 8
  store ptr @Later, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef i32 @Later(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}
