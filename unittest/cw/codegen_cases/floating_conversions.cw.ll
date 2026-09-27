define noundef double @Widen(float noundef %value) {
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

define noundef float @Narrow(double noundef %value) {
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

define noundef float @SignedSingle(i64 noundef %value) {
entry:
  %.result = alloca float, align 4
  %value.addr = alloca i64, align 8
  store i64 %value, ptr %value.addr, align 8
  %0 = load i64, ptr %value.addr, align 8
  %conv = sitofp i64 %0 to float
  store float %conv, ptr %.result, align 4
  %1 = load float, ptr %.result, align 4
  ret float %1
}

define noundef float @UnsignedSingle(i64 noundef %value) {
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

define noundef double @SignedDouble(i32 noundef %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %conv = sitofp i32 %0 to double
  store double %conv, ptr %.result, align 8
  %1 = load double, ptr %.result, align 8
  ret double %1
}

define noundef double @UnsignedDouble(i32 noundef %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %conv = uitofp i32 %0 to double
  store double %conv, ptr %.result, align 8
  %1 = load double, ptr %.result, align 8
  ret double %1
}

define noundef float @SignedByte(i8 noundef signext %value) {
entry:
  %.result = alloca float, align 4
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %conv = sitofp i8 %0 to float
  store float %conv, ptr %.result, align 4
  %1 = load float, ptr %.result, align 4
  ret float %1
}

define noundef double @UnsignedByte(i8 noundef zeroext %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca i8, align 1
  store i8 %value, ptr %value.addr, align 1
  %0 = load i8, ptr %value.addr, align 1
  %conv = uitofp i8 %0 to double
  store double %conv, ptr %.result, align 8
  %1 = load double, ptr %.result, align 8
  ret double %1
}

define noundef float @RoundedInteger() {
entry:
  %.result = alloca float, align 4
  store float f0x4B800000, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @NegativeInteger() {
entry:
  %.result = alloca double, align 8
  store double f0xC170000010000000, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @NarrowOverflow() {
entry:
  %.result = alloca float, align 4
  store float +inf, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef float @NarrowUnderflow() {
entry:
  %.result = alloca float, align 4
  store float -0.000000e+00, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef float @NarrowSubnormal() {
entry:
  %.result = alloca float, align 4
  store float 1.401300e-45, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}
