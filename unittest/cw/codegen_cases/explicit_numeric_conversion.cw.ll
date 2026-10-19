define noundef i32 @"cw:ZeroInteger:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 0, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef float @"cw:ZeroFloat:func()f32"() {
entry:
  %.result = alloca float, align 4
  store float 0.000000e+00, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef i64 @"cw:ToSize:func(i32)usize"(i32 noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %conv = sext i32 %0 to i64
  store i64 %conv, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef signext i16 @"cw:FromSize:func(usize)i16"(i64 noundef %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %conv = trunc i64 %0 to i16
  store i16 %conv, ptr %.result, align 2
  %1 = load i16, ptr %.result, align 2
  ret i16 %1
}

define noundef i32 @"cw:Same:func(i32)i32"(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef float @"cw:FloatSize:func(usize)f32"(i64 noundef %value) {
entry:
  %.result = alloca float, align 4
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %conv = uitofp i64 %0 to float
  store float %conv, ptr %.result, align 4
  %1 = load float, ptr %.result, align 4
  ret float %1
}

define noundef i64 @"cw:SizeFloat:func(f64)isize"(double noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = call i64 @llvm.fptosi.sat.i64.f64(double %0)
  store i64 %conv, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef float @"cw:NarrowFloat:func(f64)f32"(double noundef %value) {
entry:
  %.result = alloca float, align 4
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = fptrunc double %0 to float
  store float %conv, ptr %.result, align 4
  %1 = load float, ptr %.result, align 4
  ret float %1
}

define noundef double @"cw:WidenFloat:func(f32)f64"(float noundef %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %conv = fpext float %0 to double
  store double %conv, ptr %.result, align 8
  %1 = load double, ptr %.result, align 8
  ret double %1
}

define noundef i32 @"cw:Advance:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define void @"cw:Discard:func(&mut i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %conv = sitofp i32 %1 to double
  ret void
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fptosi.sat.i64.f64(double) #0

attributes #0 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
