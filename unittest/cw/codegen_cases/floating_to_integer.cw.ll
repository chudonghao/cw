define noundef signext i8 @Signed8(double noundef %value) {
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

define noundef zeroext i8 @Unsigned8(double noundef %value) {
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

define noundef signext i16 @Signed16(double noundef %value) {
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

define noundef zeroext i16 @Unsigned16(double noundef %value) {
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

define noundef i32 @Signed32(double noundef %value) {
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

define noundef i32 @Unsigned32(double noundef %value) {
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

define noundef i64 @Signed64(double noundef %value) {
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

define noundef i64 @Unsigned64(double noundef %value) {
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

define noundef i32 @SignedSingle(float noundef %value) {
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

define noundef i64 @UnsignedSingle(float noundef %value) {
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

define noundef i32 @Fraction() {
entry:
  %.result = alloca i32, align 4
  %conv = call i32 @llvm.fptosi.sat.i32.f64(double -3.900000e+00)
  store i32 %conv, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef zeroext i8 @ClampByte() {
entry:
  %.result = alloca i8, align 1
  %conv = call i8 @llvm.fptoui.sat.i8.f64(double 3.000000e+02)
  store i8 %conv, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define noundef signext i8 @ClampSignedByte() {
entry:
  %.result = alloca i8, align 1
  %conv = call i8 @llvm.fptosi.sat.i8.f64(double 1.280000e+02)
  store i8 %conv, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define noundef zeroext i8 @ClampNegative() {
entry:
  %.result = alloca i8, align 1
  %conv = call i8 @llvm.fptoui.sat.i8.f64(double -5.000000e-01)
  store i8 %conv, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define noundef i32 @NaNToZero() {
entry:
  %.result = alloca i32, align 4
  %conv = call i32 @llvm.fptosi.sat.i32.f64(double +qnan)
  store i32 %conv, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i64 @PositiveInfinity() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptosi.sat.i64.f64(double +inf)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @NegativeInfinity() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptosi.sat.i64.f64(double -inf)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @UnsignedInfinity() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptoui.sat.i64.f64(double +inf)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @UnsignedNegativeInfinity() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptoui.sat.i64.f64(double -inf)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @SignedUpperBoundary() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptosi.sat.i64.f64(double f0x43E0000000000000)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i64 @UnsignedUpperBoundary() {
entry:
  %.result = alloca i64, align 8
  %conv = call i64 @llvm.fptoui.sat.i64.f64(double f0x43F0000000000000)
  store i64 %conv, ptr %.result, align 8
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define noundef i32 @NegativeZero() {
entry:
  %.result = alloca i32, align 4
  %conv = call i32 @llvm.fptosi.sat.i32.f64(double -0.000000e+00)
  store i32 %conv, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef zeroext i8 @ViaInteger() {
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
