define noundef float @"cw:SingleArithmetic:func(f32,f32)f32"(float noundef %left, float noundef %right) {
entry:
  %.result = alloca float, align 4
  %left.addr = alloca float, align 4
  %right.addr = alloca float, align 4
  store float %left, ptr %left.addr, align 4
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %left.addr, align 4
  %1 = load float, ptr %right.addr, align 4
  %fneg = fneg float %1
  %add = fadd float %0, %fneg
  %2 = load float, ptr %left.addr, align 4
  %3 = load float, ptr %right.addr, align 4
  %sub = fsub float %2, %3
  %mul = fmul float %add, %sub
  %4 = load float, ptr %right.addr, align 4
  %div = fdiv float %mul, %4
  store float %div, ptr %.result, align 4
  %5 = load float, ptr %.result, align 4
  ret float %5
}

define noundef double @"cw:DoubleArithmetic:func(f64,f64)f64"(double noundef %left, double noundef %right) {
entry:
  %.result = alloca double, align 8
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %fneg = fneg double %1
  %add = fadd double %0, %fneg
  %2 = load double, ptr %left.addr, align 8
  %3 = load double, ptr %right.addr, align 8
  %sub = fsub double %2, %3
  %mul = fmul double %add, %sub
  %4 = load double, ptr %right.addr, align 8
  %div = fdiv double %mul, %4
  store double %div, ptr %.result, align 8
  %5 = load double, ptr %.result, align 8
  ret double %5
}

define noundef double @"cw:MultiplyAdd:func(f64,f64,f64)f64"(double noundef %left, double noundef %right, double noundef %addend) {
entry:
  %.result = alloca double, align 8
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  %addend.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  store double %addend, ptr %addend.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %mul = fmul double %0, %1
  %2 = load double, ptr %addend.addr, align 8
  %add = fadd double %mul, %2
  store double %add, ptr %.result, align 8
  %3 = load double, ptr %.result, align 8
  ret double %3
}

define noundef float @"cw:Grouped:func(f32,f32,f32)f32"(float noundef %first, float noundef %second, float noundef %third) {
entry:
  %.result = alloca float, align 4
  %first.addr = alloca float, align 4
  %second.addr = alloca float, align 4
  %third.addr = alloca float, align 4
  store float %first, ptr %first.addr, align 4
  store float %second, ptr %second.addr, align 4
  store float %third, ptr %third.addr, align 4
  %0 = load float, ptr %first.addr, align 4
  %1 = load float, ptr %second.addr, align 4
  %2 = load float, ptr %third.addr, align 4
  %add = fadd float %1, %2
  %add1 = fadd float %0, %add
  store float %add1, ptr %.result, align 4
  %3 = load float, ptr %.result, align 4
  ret float %3
}

define noundef double @"cw:PositiveInfinity:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double +inf, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @"cw:NegativeInfinity:func()f32"() {
entry:
  %.result = alloca float, align 4
  store float -inf, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef double @"cw:Overflow:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double +inf, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef double @"cw:NegativeUnderflow:func()f64"() {
entry:
  %.result = alloca double, align 8
  store double -0.000000e+00, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @"cw:GradualUnderflow:func()f32"() {
entry:
  %.result = alloca float, align 4
  store float f0x00400000, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}

define noundef float @"cw:RoundEachStep:func()f32"() {
entry:
  %.result = alloca float, align 4
  store float 0.000000e+00, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}
