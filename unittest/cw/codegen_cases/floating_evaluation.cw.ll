define noundef double @Bump(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load float, ptr %0, align 4
  %add = fadd float %1, 1.000000e+00
  %2 = load ptr, ptr %value.addr, align 8
  store float %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8
  %4 = load float, ptr %3, align 4
  %conv = fpext float %4 to double
  store double %conv, ptr %.result, align 8
  %5 = load double, ptr %.result, align 8
  ret double %5
}

define noundef double @ReadBeforeBump(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load float, ptr %0, align 4
  %conv = fpext float %1 to double
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef double @Bump(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %add = fadd double %conv, %call
  store double %add, ptr %.result, align 8
  %3 = load double, ptr %.result, align 8
  ret double %3
}

define noundef double @Pair(double noundef %first, double noundef %second) {
entry:
  %.result = alloca double, align 8
  %first.addr = alloca double, align 8
  %second.addr = alloca double, align 8
  store double %first, ptr %first.addr, align 8
  store double %second, ptr %second.addr, align 8
  %0 = load double, ptr %first.addr, align 8
  %1 = load double, ptr %second.addr, align 8
  %add = fadd double %0, %1
  store double %add, ptr %.result, align 8
  %2 = load double, ptr %.result, align 8
  ret double %2
}

define noundef double @ArgumentOrder(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca double, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load float, ptr %0, align 4
  %conv = fpext float %1 to double
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef double @Bump(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %call1 = call noundef double @Pair(double noundef %conv, double noundef %call)
  store double %call1, ptr %.result, align 8
  %3 = load double, ptr %.result, align 8
  ret double %3
}

define noundef double @Choose(i1 noundef zeroext %flag, float noundef %left, double noundef %right) {
entry:
  %.result = alloca double, align 8
  %flag.addr = alloca i8, align 1
  %left.addr = alloca float, align 4
  %right.addr = alloca double, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store float %left, ptr %left.addr, align 4
  store double %right, ptr %right.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load float, ptr %left.addr, align 4
  %conv = fpext float %1 to double
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load double, ptr %right.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi double [ %conv, %cond.true ], [ %2, %cond.false ]
  store double %cond, ptr %.result, align 8
  %3 = load double, ptr %.result, align 8
  ret double %3
}

define noundef double @Sum(i32 noundef %limit) {
entry:
  %.result = alloca double, align 8
  %limit.addr = alloca i32, align 4
  %index = alloca i32, align 4
  %sum = alloca double, align 8
  store i32 %limit, ptr %limit.addr, align 4
  store i32 0, ptr %index, align 4
  store double 0.000000e+00, ptr %sum, align 8
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load i32, ptr %index, align 4
  %1 = load i32, ptr %limit.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %2 = load double, ptr %sum, align 8
  %3 = load i32, ptr %index, align 4
  %conv = sitofp i32 %3 to double
  %add = fadd double %2, %conv
  store double %add, ptr %sum, align 8
  %4 = load i32, ptr %index, align 4
  %add1 = add i32 %4, 1
  store i32 %add1, ptr %index, align 4
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %5 = load double, ptr %sum, align 8
  store double %5, ptr %.result, align 8
  %6 = load double, ptr %.result, align 8
  ret double %6
}

define noundef nonnull align 4 dereferenceable(4) ptr @Select(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load ptr, ptr %right.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ %1, %cond.true ], [ %2, %cond.false ]
  store ptr %cond, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define void @WriteChosen(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right, double noundef %value) {
entry:
  %flag.addr = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %value.addr = alloca double, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %conv = fptrunc double %0 to float
  %1 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  %2 = load ptr, ptr %left.addr, align 8
  %3 = load ptr, ptr %right.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Select(i1 noundef zeroext %loadedv, ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  store float %conv, ptr %call, align 4
  ret void
}
