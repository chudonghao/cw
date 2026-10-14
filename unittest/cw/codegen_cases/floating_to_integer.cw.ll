define noundef signext i8 @"cw:Signed8:func(f64)i8"(double noundef %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = call i8 @llvm.fptosi.sat.i8.f64(double %0)
  store i8 %conv, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

define noundef zeroext i8 @"cw:Unsigned8:func(f64)u8"(double noundef %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = call i8 @llvm.fptoui.sat.i8.f64(double %0)
  store i8 %conv, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

define noundef signext i16 @"cw:Signed16:func(f64)i16"(double noundef %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = call i16 @llvm.fptosi.sat.i16.f64(double %0)
  store i16 %conv, ptr %.result, align 2
  %1 = load i16, ptr %.result, align 2
  ret i16 %1
}

define noundef zeroext i16 @"cw:Unsigned16:func(f64)u16"(double noundef %value) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = call i16 @llvm.fptoui.sat.i16.f64(double %0)
  store i16 %conv, ptr %.result, align 2
  %1 = load i16, ptr %.result, align 2
  ret i16 %1
}

define noundef i32 @"cw:Signed32:func(f64)i32"(double noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = call i32 @llvm.fptosi.sat.i32.f64(double %0)
  store i32 %conv, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:Unsigned32:func(f64)u32"(double noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = call i32 @llvm.fptoui.sat.i32.f64(double %0)
  store i32 %conv, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i64 @"cw:Signed64:func(f64)i64"(double noundef %value) {
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

define noundef i64 @"cw:Unsigned64:func(f64)u64"(double noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = call i64 @llvm.fptoui.sat.i64.f64(double %0)
  store i64 %conv, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i32 @"cw:SignedSingle:func(f32)i32"(float noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %conv = call i32 @llvm.fptosi.sat.i32.f32(float %0)
  store i32 %conv, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i64 @"cw:UnsignedSingle:func(f32)u64"(float noundef %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %conv = call i64 @llvm.fptoui.sat.i64.f32(float %0)
  store i64 %conv, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i32 @"cw:Fraction:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %conv = call i32 @llvm.fptosi.sat.i32.f64(double -3.900000e+00)
  store i32 %conv, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef zeroext i8 @"cw:ClampByte:func()u8"() {
entry:
  %.result = alloca i8, align 1
  %conv = call i8 @llvm.fptoui.sat.i8.f64(double 3.000000e+02)
  store i8 %conv, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define noundef signext i8 @"cw:ClampSignedByte:func()i8"() {
entry:
  %.result = alloca i8, align 1
  %conv = call i8 @llvm.fptosi.sat.i8.f64(double 1.280000e+02)
  store i8 %conv, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define noundef zeroext i8 @"cw:ClampNegative:func()u8"() {
entry:
  %.result = alloca i8, align 1
  %conv = call i8 @llvm.fptoui.sat.i8.f64(double -5.000000e-01)
  store i8 %conv, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define noundef i32 @"cw:NaNToZero:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %conv = call i32 @llvm.fptosi.sat.i32.f64(double +qnan)
  store i32 %conv, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i64 @"cw:PositiveInfinity:func()i64"() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptosi.sat.i64.f64(double +inf)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @"cw:NegativeInfinity:func()i64"() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptosi.sat.i64.f64(double -inf)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @"cw:UnsignedInfinity:func()u64"() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptoui.sat.i64.f64(double +inf)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @"cw:UnsignedNegativeInfinity:func()u64"() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptoui.sat.i64.f64(double -inf)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @"cw:SignedUpperBoundary:func()i64"() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptosi.sat.i64.f64(double f0x43E0000000000000)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @"cw:UnsignedUpperBoundary:func()u64"() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptoui.sat.i64.f64(double f0x43F0000000000000)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i32 @"cw:NegativeZero:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %conv = call i32 @llvm.fptosi.sat.i32.f64(double -0.000000e+00)
  store i32 %conv, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef zeroext i8 @"cw:ViaInteger:func()u8"() {
entry:
  %.result = alloca i8, align 1
  %value = alloca i32, align 4
  %conv = call i32 @llvm.fptosi.sat.i32.f64(double 3.000000e+02)
  store i32 %conv, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %conv1 = trunc i32 %0 to i8
  store i8 %conv1, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.fptosi.sat.i8.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.fptoui.sat.i8.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i16 @llvm.fptosi.sat.i16.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i16 @llvm.fptoui.sat.i16.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fptosi.sat.i32.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fptoui.sat.i32.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fptosi.sat.i64.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fptoui.sat.i64.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fptosi.sat.i32.f32(float) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fptoui.sat.i64.f32(float) #0

attributes #0 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
