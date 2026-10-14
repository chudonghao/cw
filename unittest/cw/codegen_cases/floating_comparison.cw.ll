define noundef zeroext i1 @"cw:Equal:func(f32,f32)bool"(float noundef %left, float noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca float, align 4
  %right.addr = alloca float, align 4
  store float %left, ptr %left.addr, align 4
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %left.addr, align 4
  %1 = load float, ptr %right.addr, align 4
  %cmp = fcmp oeq float %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NotEqual:func(f64,f64)bool"(double noundef %left, double noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %cmp = fcmp une double %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:Less:func(f32,f32)bool"(float noundef %left, float noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca float, align 4
  %right.addr = alloca float, align 4
  store float %left, ptr %left.addr, align 4
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %left.addr, align 4
  %1 = load float, ptr %right.addr, align 4
  %cmp = fcmp olt float %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:LessEqual:func(f64,f64)bool"(double noundef %left, double noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %cmp = fcmp ole double %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:Greater:func(f32,f32)bool"(float noundef %left, float noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca float, align 4
  %right.addr = alloca float, align 4
  store float %left, ptr %left.addr, align 4
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %left.addr, align 4
  %1 = load float, ptr %right.addr, align 4
  %cmp = fcmp ogt float %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:GreaterEqual:func(f64,f64)bool"(double noundef %left, double noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca double, align 8
  %right.addr = alloca double, align 8
  store double %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %left.addr, align 8
  %1 = load double, ptr %right.addr, align 8
  %cmp = fcmp oge double %0, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:MixedLess:func(i32,f64)bool"(i32 noundef %left, double noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca double, align 8
  store i32 %left, ptr %left.addr, align 4
  store double %right, ptr %right.addr, align 8
  %0 = load i32, ptr %left.addr, align 4
  %conv = sitofp i32 %0 to double
  %1 = load double, ptr %right.addr, align 8
  %cmp = fcmp olt double %conv, %1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NaNEqual:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 0, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NaNNotEqual:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 1, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NaNLess:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 0, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NaNLessEqual:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 0, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NaNGreater:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 0, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:NaNGreaterEqual:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 0, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef zeroext i1 @"cw:SignedZerosEqual:func()bool"() {
entry:
  %.result = alloca i8, align 1
  store i8 1, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}
