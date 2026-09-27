define noundef float @Single(float noundef %value) {
entry:
  %.result = alloca float, align 4
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  store float %0, ptr %.result, align 4
  %1 = load float, ptr %.result, align 4
  ret float %1
}

define noundef double @Double(double noundef %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  store double %0, ptr %.result, align 8
  %1 = load double, ptr %.result, align 8
  ret double %1
}

define noundef double @Read(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load double, ptr %0, align 8
  store double %1, ptr %.result, align 8
  %2 = load double, ptr %.result, align 8
  ret double %2
}

define noundef nonnull align 4 dereferenceable(4) ptr @Locate(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @Assign(ptr noundef nonnull align 4 dereferenceable(4) %target, double noundef %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca double, align 8
  store ptr %target, ptr %target.addr, align 8
  store double %source, ptr %source.addr, align 8
  %0 = load double, ptr %source.addr, align 8
  %conv = fptrunc double %0 to float
  %1 = load ptr, ptr %target.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Locate(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store float %conv, ptr %call, align 4
  ret void
}

define noundef double @Forward(float noundef %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %conv = fpext float %0 to double
  %call = call noundef double @Double(double noundef %conv)
  store double %call, ptr %.result, align 8
  %1 = load double, ptr %.result, align 8
  ret double %1
}

define noundef double @Temporary() {
entry:
  %.result = alloca double, align 8
  %temporary = alloca double, align 8
  store double 5.000000e-01, ptr %temporary, align 8
  %call = call noundef double @Read(ptr noundef nonnull align 8 dereferenceable(8) %temporary)
  store double %call, ptr %.result, align 8
  %0 = load double, ptr %.result, align 8
  ret double %0
}

define noundef float @ReadMove(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca float, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load float, ptr %0, align 4
  store float %1, ptr %.result, align 4
  %2 = load float, ptr %.result, align 4
  ret float %2
}

define noundef float @MoveLocal() {
entry:
  %.result = alloca float, align 4
  %value = alloca float, align 4
  store float 2.500000e+00, ptr %value, align 4
  %call = call noundef float @ReadMove(ptr noundef nonnull align 4 dereferenceable(4) %value)
  store float %call, ptr %.result, align 4
  %0 = load float, ptr %.result, align 4
  ret float %0
}
