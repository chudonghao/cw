define noundef float @"cw:SingleTenth:func()f32"() {
entry:
  %.result = alloca float, align 4
  store float 1.000000e-01, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @"cw:DoubleTenth:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double 1.000000e-01, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @"cw:SingleSubnormal:func()f32"() {
entry:
  %.result = alloca float, align 4
  store float 1.401300e-45, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @"cw:DoubleSubnormal:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double 4.940660e-324, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef double @"cw:Underflow:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double 0.000000e+00, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @"cw:NegativeZero:func()f32"() {
entry:
  %.result = alloca float, align 4
  store float -0.000000e+00, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @"cw:NegatedZero:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double 0.000000e+00, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef double @"cw:WidenedSingle:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double f0x3FB99999A0000000, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef double @"cw:ExplicitDouble:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double 5.000000e+02, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @"cw:DirectSingleRounding:func()f32"() {
entry:
  %.result = alloca float, align 4
  store float f0x3F800001, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @"cw:DoubleNegativeZero:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double -0.000000e+00, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}
