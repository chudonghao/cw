define noundef signext i8 @"cw:ByteArithmetic:func(&mut i8,i8)i8"(ptr noundef nonnull align 1 dereferenceable(1) %left, i8 noundef signext %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %right.addr, align 1
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i8, ptr %1, align 1
  %add = add i8 %2, %0
  store i8 %add, ptr %1, align 1
  %3 = load i8, ptr %right.addr, align 1
  %4 = load ptr, ptr %left.addr, align 8
  %5 = load i8, ptr %4, align 1
  %sub = sub i8 %5, %3
  store i8 %sub, ptr %4, align 1
  %6 = load i8, ptr %right.addr, align 1
  %7 = load ptr, ptr %left.addr, align 8
  %8 = load i8, ptr %7, align 1
  %mul = mul i8 %8, %6
  store i8 %mul, ptr %7, align 1
  %9 = load i8, ptr %right.addr, align 1
  %10 = load ptr, ptr %left.addr, align 8
  %11 = load i8, ptr %10, align 1
  %12 = icmp eq i8 %9, -1
  br i1 %12, label %div.negone, label %div.normal

div.negone:                                       ; preds = %entry
  %sub1 = sub i8 0, %11
  br label %div.end

div.normal:                                       ; preds = %entry
  %div = sdiv i8 %11, %9
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div2 = phi i8 [ %sub1, %div.negone ], [ %div, %div.normal ]
  store i8 %div2, ptr %10, align 1
  %13 = load i8, ptr %right.addr, align 1
  %14 = load ptr, ptr %left.addr, align 8
  %15 = load i8, ptr %14, align 1
  %16 = icmp eq i8 %13, -1
  br i1 %16, label %rem.negone, label %rem.normal

rem.negone:                                       ; preds = %div.end
  br label %rem.end

rem.normal:                                       ; preds = %div.end
  %rem = srem i8 %15, %13
  br label %rem.end

rem.end:                                          ; preds = %rem.normal, %rem.negone
  %rem3 = phi i8 [ 0, %rem.negone ], [ %rem, %rem.normal ]
  store i8 %rem3, ptr %14, align 1
  %17 = load i8, ptr %right.addr, align 1
  %18 = load ptr, ptr %left.addr, align 8
  %19 = load i8, ptr %18, align 1
  %and = and i8 %19, %17
  store i8 %and, ptr %18, align 1
  %20 = load i8, ptr %right.addr, align 1
  %21 = load ptr, ptr %left.addr, align 8
  %22 = load i8, ptr %21, align 1
  %or = or i8 %22, %20
  store i8 %or, ptr %21, align 1
  %23 = load i8, ptr %right.addr, align 1
  %24 = load ptr, ptr %left.addr, align 8
  %25 = load i8, ptr %24, align 1
  %xor = xor i8 %25, %23
  store i8 %xor, ptr %24, align 1
  %26 = load ptr, ptr %left.addr, align 8
  %27 = load i8, ptr %26, align 1
  store i8 %27, ptr %.result, align 1
  %28 = load i8, ptr %.result, align 1
  ret i8 %28
}

define noundef signext i8 @"cw:MixedAdd:func(&mut i8,i32)i8"(ptr noundef nonnull align 1 dereferenceable(1) %left, i32 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i8, ptr %1, align 1
  %conv = sext i8 %2 to i32
  %add = add i32 %conv, %0
  %conv1 = trunc i32 %add to i8
  store i8 %conv1, ptr %1, align 1
  %3 = load i8, ptr %1, align 1
  store i8 %3, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  ret i8 %4
}

define noundef signext i16 @"cw:MixedMultiply:func(&mut i16,u32)i16"(ptr noundef nonnull align 2 dereferenceable(2) %left, i32 noundef %right) {
entry:
  %.result = alloca i16, align 2
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i16, ptr %1, align 2
  %conv = sext i16 %2 to i32
  %mul = mul i32 %conv, %0
  %conv1 = trunc i32 %mul to i16
  store i16 %conv1, ptr %1, align 2
  %3 = load i16, ptr %1, align 2
  store i16 %3, ptr %.result, align 2
  %4 = load i16, ptr %.result, align 2
  ret i16 %4
}

define noundef i32 @"cw:SignedDivide:func(&mut i32,i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i32, ptr %1, align 4
  %3 = icmp eq i32 %0, -1
  br i1 %3, label %div.negone, label %div.normal

div.negone:                                       ; preds = %entry
  %sub = sub i32 0, %2
  br label %div.end

div.normal:                                       ; preds = %entry
  %div = sdiv i32 %2, %0
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div1 = phi i32 [ %sub, %div.negone ], [ %div, %div.normal ]
  store i32 %div1, ptr %1, align 4
  %4 = load i32, ptr %1, align 4
  store i32 %4, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define noundef i64 @"cw:SignedRemainder:func(&mut i64,i64)i64"(ptr noundef nonnull align 8 dereferenceable(8) %left, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i64, ptr %1, align 8
  %3 = icmp eq i64 %0, -1
  br i1 %3, label %rem.negone, label %rem.normal

rem.negone:                                       ; preds = %entry
  br label %rem.end

rem.normal:                                       ; preds = %entry
  %rem = srem i64 %2, %0
  br label %rem.end

rem.end:                                          ; preds = %rem.normal, %rem.negone
  %rem1 = phi i64 [ 0, %rem.negone ], [ %rem, %rem.normal ]
  store i64 %rem1, ptr %1, align 8
  %4 = load i64, ptr %1, align 8
  store i64 %4, ptr %.result, align 8
  %5 = load i64, ptr %.result, align 8
  ret i64 %5
}

define noundef i64 @"cw:UnsignedDivide:func(&mut u64,u64)u64"(ptr noundef nonnull align 8 dereferenceable(8) %left, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i64, ptr %1, align 8
  %div = udiv i64 %2, %0
  store i64 %div, ptr %1, align 8
  %3 = load i64, ptr %1, align 8
  store i64 %3, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef zeroext i16 @"cw:UnsignedRemainder:func(&mut u16,u16)u16"(ptr noundef nonnull align 2 dereferenceable(2) %left, i16 noundef zeroext %right) {
entry:
  %.result = alloca i16, align 2
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i16, align 2
  store ptr %left, ptr %left.addr, align 8
  store i16 %right, ptr %right.addr, align 2
  %0 = load i16, ptr %right.addr, align 2
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i16, ptr %1, align 2
  %rem = urem i16 %2, %0
  store i16 %rem, ptr %1, align 2
  %3 = load i16, ptr %1, align 2
  store i16 %3, ptr %.result, align 2
  %4 = load i16, ptr %.result, align 2
  ret i16 %4
}

define noundef float @"cw:FloatArithmetic:func(&mut f32,f32)f32"(ptr noundef nonnull align 4 dereferenceable(4) %left, float noundef %right) {
entry:
  %.result = alloca float, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca float, align 4
  store ptr %left, ptr %left.addr, align 8
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load float, ptr %1, align 4
  %add = fadd float %2, %0
  store float %add, ptr %1, align 4
  %3 = load float, ptr %right.addr, align 4
  %4 = load ptr, ptr %left.addr, align 8
  %5 = load float, ptr %4, align 4
  %sub = fsub float %5, %3
  store float %sub, ptr %4, align 4
  %6 = load float, ptr %right.addr, align 4
  %7 = load ptr, ptr %left.addr, align 8
  %8 = load float, ptr %7, align 4
  %mul = fmul float %8, %6
  store float %mul, ptr %7, align 4
  %9 = load float, ptr %right.addr, align 4
  %10 = load ptr, ptr %left.addr, align 8
  %11 = load float, ptr %10, align 4
  %div = fdiv float %11, %9
  store float %div, ptr %10, align 4
  %12 = load ptr, ptr %left.addr, align 8
  %13 = load float, ptr %12, align 4
  store float %13, ptr %.result, align 4
  %14 = load float, ptr %.result, align 4
  ret float %14
}

define noundef float @"cw:FloatWriteback:func(&mut f32,f64)f32"(ptr noundef nonnull align 4 dereferenceable(4) %left, double noundef %right) {
entry:
  %.result = alloca float, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca double, align 8
  store ptr %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load float, ptr %1, align 4
  %conv = fpext float %2 to double
  %add = fadd double %conv, %0
  %conv1 = fptrunc double %add to float
  store float %conv1, ptr %1, align 4
  %3 = load float, ptr %1, align 4
  store float %3, ptr %.result, align 4
  %4 = load float, ptr %.result, align 4
  ret float %4
}

define noundef double @"cw:IntegerToFloat:func(&mut f64,i64)f64"(ptr noundef nonnull align 8 dereferenceable(8) %left, i64 noundef %right) {
entry:
  %.result = alloca double, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %conv = sitofp i64 %0 to double
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load double, ptr %1, align 8
  %mul = fmul double %2, %conv
  store double %mul, ptr %1, align 8
  %3 = load double, ptr %1, align 8
  store double %3, ptr %.result, align 8
  %4 = load double, ptr %.result, align 8
  ret double %4
}

define noundef i32 @"cw:FloatToInteger:func(&mut i32,f64)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, double noundef %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca double, align 8
  store ptr %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load double, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i32, ptr %1, align 4
  %conv = sitofp i32 %2 to double
  %add = fadd double %conv, %0
  %conv1 = call i32 @llvm.fptosi.sat.i32.f64(double %add)
  store i32 %conv1, ptr %1, align 4
  %3 = load i32, ptr %1, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i64 @"cw:UnsignedFloatToInteger:func(&mut u64,f32)u64"(ptr noundef nonnull align 8 dereferenceable(8) %left, float noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca float, align 4
  store ptr %left, ptr %left.addr, align 8
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i64, ptr %1, align 8
  %conv = uitofp i64 %2 to float
  %mul = fmul float %conv, %0
  %conv1 = call i64 @llvm.fptoui.sat.i64.f32(float %mul)
  store i64 %conv1, ptr %1, align 8
  %3 = load i64, ptr %1, align 8
  store i64 %3, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef signext i8 @"cw:ByteShift:func(&mut i8,u64)i8"(ptr noundef nonnull align 1 dereferenceable(1) %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i8, ptr %1, align 1
  %shift.count = and i64 %0, 7
  %shift.cast = trunc i64 %shift.count to i8
  %shl = shl i8 %2, %shift.cast
  store i8 %shl, ptr %1, align 1
  %3 = load i8, ptr %1, align 1
  store i8 %3, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  ret i8 %4
}

define noundef zeroext i8 @"cw:ByteRight:func(&mut u8,i64)u8"(ptr noundef nonnull align 1 dereferenceable(1) %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i8, ptr %1, align 1
  %shift.count = and i64 %0, 7
  %shift.cast = trunc i64 %shift.count to i8
  %lshr = lshr i8 %2, %shift.cast
  store i8 %lshr, ptr %1, align 1
  %3 = load i8, ptr %1, align 1
  store i8 %3, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  ret i8 %4
}

define noundef i32 @"cw:SignedRight:func(&mut i32,i8)i32"(ptr noundef nonnull align 4 dereferenceable(4) %left, i8 noundef signext %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %right.addr, align 1
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i32, ptr %1, align 4
  %shift.count = and i8 %0, 31
  %shift.cast = zext i8 %shift.count to i32
  %ashr = ashr i32 %2, %shift.cast
  store i32 %ashr, ptr %1, align 4
  %3 = load i32, ptr %1, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef zeroext i16 @"cw:WordShift:func(&mut u16,i8)u16"(ptr noundef nonnull align 2 dereferenceable(2) %left, i8 noundef signext %right) {
entry:
  %.result = alloca i16, align 2
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %right.addr, align 1
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i16, ptr %1, align 2
  %shift.count = and i8 %0, 15
  %shift.cast = zext i8 %shift.count to i16
  %shl = shl i16 %2, %shift.cast
  store i16 %shl, ptr %1, align 2
  %3 = load i16, ptr %1, align 2
  store i16 %3, ptr %.result, align 2
  %4 = load i16, ptr %.result, align 2
  ret i16 %4
}

define noundef i64 @"cw:WideShift:func(&mut i64,u8)i64"(ptr noundef nonnull align 8 dereferenceable(8) %left, i8 noundef zeroext %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %right.addr, align 1
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i64, ptr %1, align 8
  %shift.count = and i8 %0, 63
  %shift.cast = zext i8 %shift.count to i64
  %shl = shl i64 %2, %shift.cast
  store i64 %shl, ptr %1, align 8
  %3 = load i64, ptr %1, align 8
  store i64 %3, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef i64 @"cw:SizeShift:func(&mut usize,i32)usize"(ptr noundef nonnull align 8 dereferenceable(8) %left, i32 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i64, ptr %1, align 8
  %shift.count = and i32 %0, 63
  %shift.cast = zext i32 %shift.count to i64
  %shl = shl i64 %2, %shift.cast
  store i64 %shl, ptr %1, align 8
  %3 = load i64, ptr %1, align 8
  store i64 %3, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef i64 @"cw:SignedSizeRight:func(&mut isize,u64)isize"(ptr noundef nonnull align 8 dereferenceable(8) %left, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i64, ptr %1, align 8
  %shift.count = and i64 %0, 63
  %ashr = ashr i64 %2, %shift.count
  store i64 %ashr, ptr %1, align 8
  %3 = load i64, ptr %1, align 8
  store i64 %3, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef zeroext i8 @"cw:FixedBySize:func(&mut u8,usize)u8"(ptr noundef nonnull align 1 dereferenceable(1) %left, i64 noundef %right) {
entry:
  %.result = alloca i8, align 1
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %2 = load i8, ptr %1, align 1
  %shift.count = and i64 %0, 7
  %shift.cast = trunc i64 %shift.count to i8
  %shl = shl i8 %2, %shift.cast
  store i8 %shl, ptr %1, align 1
  %3 = load i8, ptr %1, align 1
  store i8 %3, ptr %.result, align 1
  %4 = load i8, ptr %.result, align 1
  ret i8 %4
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fptosi.sat.i32.f64(double) #0

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fptoui.sat.i64.f32(float) #0

attributes #0 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
