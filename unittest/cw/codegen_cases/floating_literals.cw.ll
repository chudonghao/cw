define noundef float @SingleTenth() {
entry:
  %.result = alloca float, align 4
  store float 1.000000e-01, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @DoubleTenth() {
entry:
  %.result = alloca double, align 8
  store double 1.000000e-01, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @SingleSubnormal() {
entry:
  %.result = alloca float, align 4
  store float 1.401300e-45, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @DoubleSubnormal() {
entry:
  %.result = alloca double, align 8
  store double 4.940660e-324, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef double @Underflow() {
entry:
  %.result = alloca double, align 8
  store double 0.000000e+00, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @NegativeZero() {
entry:
  %.result = alloca float, align 4
  store float -0.000000e+00, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @NegatedZero() {
entry:
  %.result = alloca double, align 8
  store double 0.000000e+00, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef double @WidenedSingle() {
entry:
  %.result = alloca double, align 8
  store double f0x3FB99999A0000000, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}
