; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names compound_arithmetic.cpp -o -
; ModuleID = 'compound_arithmetic.cpp'
source_filename = "compound_arithmetic.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z14ByteArithmeticRaa(ptr noundef nonnull align 1 dereferenceable(1) %left, i8 noundef signext %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %right, ptr %right.addr, align 1
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %conv = sext i8 %1 to i32
  %2 = load i8, ptr %right.addr, align 1
  %conv1 = sext i8 %2 to i32
  %add = add nsw i32 %conv, %conv1
  %conv2 = trunc i32 %add to i8
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv2, ptr %3, align 1
  %4 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %5 = load i8, ptr %4, align 1
  %conv3 = sext i8 %5 to i32
  %6 = load i8, ptr %right.addr, align 1
  %conv4 = sext i8 %6 to i32
  %sub = sub nsw i32 %conv3, %conv4
  %conv5 = trunc i32 %sub to i8
  %7 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv5, ptr %7, align 1
  %8 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %9 = load i8, ptr %8, align 1
  %conv6 = sext i8 %9 to i32
  %10 = load i8, ptr %right.addr, align 1
  %conv7 = sext i8 %10 to i32
  %mul = mul nsw i32 %conv6, %conv7
  %conv8 = trunc i32 %mul to i8
  %11 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv8, ptr %11, align 1
  %12 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %13 = load i8, ptr %12, align 1
  %conv9 = sext i8 %13 to i32
  %14 = load i8, ptr %right.addr, align 1
  %conv10 = sext i8 %14 to i32
  %div = sdiv i32 %conv9, %conv10
  %conv11 = trunc i32 %div to i8
  %15 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv11, ptr %15, align 1
  %16 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %17 = load i8, ptr %16, align 1
  %conv12 = sext i8 %17 to i32
  %18 = load i8, ptr %right.addr, align 1
  %conv13 = sext i8 %18 to i32
  %rem = srem i32 %conv12, %conv13
  %conv14 = trunc i32 %rem to i8
  %19 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv14, ptr %19, align 1
  %20 = load i8, ptr %right.addr, align 1
  %conv15 = sext i8 %20 to i32
  %21 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %22 = load i8, ptr %21, align 1
  %conv16 = sext i8 %22 to i32
  %and = and i32 %conv16, %conv15
  %conv17 = trunc i32 %and to i8
  store i8 %conv17, ptr %21, align 1
  %23 = load i8, ptr %right.addr, align 1
  %conv18 = sext i8 %23 to i32
  %24 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %25 = load i8, ptr %24, align 1
  %conv19 = sext i8 %25 to i32
  %or = or i32 %conv19, %conv18
  %conv20 = trunc i32 %or to i8
  store i8 %conv20, ptr %24, align 1
  %26 = load i8, ptr %right.addr, align 1
  %conv21 = sext i8 %26 to i32
  %27 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %28 = load i8, ptr %27, align 1
  %conv22 = sext i8 %28 to i32
  %xor = xor i32 %conv22, %conv21
  %conv23 = trunc i32 %xor to i8
  store i8 %conv23, ptr %27, align 1
  %29 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %30 = load i8, ptr %29, align 1
  ret i8 %30
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z8MixedAddRai(ptr noundef nonnull align 1 dereferenceable(1) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %conv = sext i8 %1 to i32
  %2 = load i32, ptr %right.addr, align 4
  %add = add i32 %conv, %2
  %conv1 = trunc i32 %add to i8
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv1, ptr %3, align 1
  ret i8 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i16 @_Z13MixedMultiplyRsj(ptr noundef nonnull align 2 dereferenceable(2) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %1 = load i16, ptr %0, align 2
  %conv = sext i16 %1 to i32
  %2 = load i32, ptr %right.addr, align 4
  %mul = mul i32 %conv, %2
  %conv1 = trunc i32 %mul to i16
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  store i16 %conv1, ptr %3, align 2
  ret i16 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z12SignedDivideRii(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %cmp = icmp eq i32 %0, -1
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %2 = load i32, ptr %1, align 4
  %sub = sub i32 0, %2
  br label %cond.end

cond.false:                                       ; preds = %entry
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %4 = load i32, ptr %3, align 4
  %5 = load i32, ptr %right.addr, align 4
  %div = sdiv i32 %4, %5
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %sub, %cond.true ], [ %div, %cond.false ]
  %6 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  store i32 %cond, ptr %6, align 4
  ret i32 %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z15SignedRemainderRxx(ptr noundef nonnull align 8 dereferenceable(8) %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %cmp = icmp eq i64 %0, -1
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  %2 = load i64, ptr %1, align 8
  %3 = load i64, ptr %right.addr, align 8
  %rem = srem i64 %2, %3
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i64 [ 0, %cond.true ], [ %rem, %cond.false ]
  %4 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  store i64 %cond, ptr %4, align 8
  ret i64 %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z14UnsignedDivideRyy(ptr noundef nonnull align 8 dereferenceable(8) %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  %2 = load i64, ptr %1, align 8
  %div = udiv i64 %2, %0
  store i64 %div, ptr %1, align 8
  ret i64 %div
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z17UnsignedRemainderRtt(ptr noundef nonnull align 2 dereferenceable(2) %left, i16 noundef zeroext %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i16, align 2
  store ptr %left, ptr %left.addr, align 8
  store i16 %right, ptr %right.addr, align 2
  %0 = load i16, ptr %right.addr, align 2
  %conv = zext i16 %0 to i32
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %2 = load i16, ptr %1, align 2
  %conv1 = zext i16 %2 to i32
  %rem = srem i32 %conv1, %conv
  %conv2 = trunc i32 %rem to i16
  store i16 %conv2, ptr %1, align 2
  ret i16 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z15FloatArithmeticRff(ptr noundef nonnull align 4 dereferenceable(4) %left, float noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca float, align 4
  store ptr %left, ptr %left.addr, align 8
  store float %right, ptr %right.addr, align 4
  %0 = load float, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %2 = load float, ptr %1, align 4
  %add = fadd float %2, %0
  store float %add, ptr %1, align 4
  %3 = load float, ptr %right.addr, align 4
  %4 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %5 = load float, ptr %4, align 4
  %sub = fsub float %5, %3
  store float %sub, ptr %4, align 4
  %6 = load float, ptr %right.addr, align 4
  %7 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %8 = load float, ptr %7, align 4
  %mul = fmul float %8, %6
  store float %mul, ptr %7, align 4
  %9 = load float, ptr %right.addr, align 4
  %10 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %11 = load float, ptr %10, align 4
  %div = fdiv float %11, %9
  store float %div, ptr %10, align 4
  %12 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %13 = load float, ptr %12, align 4
  ret float %13
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef float @_Z14FloatWritebackRfd(ptr noundef nonnull align 4 dereferenceable(4) %left, double noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca double, align 8
  store ptr %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %1 = load float, ptr %0, align 4
  %conv = fpext float %1 to double
  %2 = load double, ptr %right.addr, align 8
  %add = fadd double %conv, %2
  %conv1 = fptrunc double %add to float
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  store float %conv1, ptr %3, align 4
  ret float %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef double @_Z14IntegerToFloatRdx(ptr noundef nonnull align 8 dereferenceable(8) %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %conv = sitofp i64 %0 to double
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  %2 = load double, ptr %1, align 8
  %mul = fmul double %2, %conv
  store double %mul, ptr %1, align 8
  ret double %mul
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z14FloatToIntegerRid(ptr noundef nonnull align 4 dereferenceable(4) %left, double noundef %right) #1 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca double, align 8
  store ptr %left, ptr %left.addr, align 8
  store double %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %1 = load i32, ptr %0, align 4
  %conv = sitofp i32 %1 to double
  %2 = load double, ptr %right.addr, align 8
  %add = fadd double %conv, %2
  %call = call noundef i32 @_Z8SaturateIidET_T0_(double noundef %add)
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  store i32 %call, ptr %3, align 4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_Z8SaturateIidET_T0_(double noundef %value) #0 {
entry:
  %retval = alloca i32, align 4
  %value.addr = alloca double, align 8
  %upper = alloca double, align 8
  %lower = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 0, ptr %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call double @ldexp(double noundef 1.000000e+00, i32 noundef 31) #5
  store double %call1, ptr %upper, align 8
  %1 = load double, ptr %upper, align 8
  %fneg = fneg double %1
  store double %fneg, ptr %lower, align 8
  %2 = load double, ptr %value.addr, align 8
  %3 = load double, ptr %lower, align 8
  %cmp = fcmp ole double %2, %3
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef i32 @_ZNSt3__114numeric_limitsIiE6lowestB9nqe230101Ev() #4
  store i32 %call3, ptr %retval, align 4
  br label %return

if.end4:                                          ; preds = %if.end
  %4 = load double, ptr %value.addr, align 8
  %5 = load double, ptr %upper, align 8
  %cmp5 = fcmp oge double %4, %5
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef i32 @_ZNSt3__114numeric_limitsIiE3maxB9nqe230101Ev() #4
  store i32 %call7, ptr %retval, align 4
  br label %return

if.end8:                                          ; preds = %if.end4
  %6 = load double, ptr %value.addr, align 8
  %conv = fptosi double %6 to i32
  store i32 %conv, ptr %retval, align 4
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %7 = load i32, ptr %retval, align 4
  ret i32 %7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z22UnsignedFloatToIntegerRyf(ptr noundef nonnull align 8 dereferenceable(8) %left, float noundef %right) #1 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca float, align 4
  store ptr %left, ptr %left.addr, align 8
  store float %right, ptr %right.addr, align 4
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  %1 = load i64, ptr %0, align 8
  %conv = uitofp i64 %1 to float
  %2 = load float, ptr %right.addr, align 4
  %mul = fmul float %conv, %2
  %call = call noundef i64 @_Z8SaturateIyfET_T0_(float noundef %mul)
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  store i64 %call, ptr %3, align 8
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i64 @_Z8SaturateIyfET_T0_(float noundef %value) #0 {
entry:
  %retval = alloca i64, align 8
  %value.addr = alloca float, align 4
  %upper = alloca float, align 4
  %lower = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101Ef(float noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i64 0, ptr %retval, align 8
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call noundef float @_ZNSt3__16__math5ldexpB9nqe230101Efi(float noundef 1.000000e+00, i32 noundef 64) #4
  store float %call1, ptr %upper, align 4
  store float 0.000000e+00, ptr %lower, align 4
  %1 = load float, ptr %value.addr, align 4
  %cmp = fcmp ole float %1, 0.000000e+00
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef i64 @_ZNSt3__114numeric_limitsIyE6lowestB9nqe230101Ev() #4
  store i64 %call3, ptr %retval, align 8
  br label %return

if.end4:                                          ; preds = %if.end
  %2 = load float, ptr %value.addr, align 4
  %3 = load float, ptr %upper, align 4
  %cmp5 = fcmp oge float %2, %3
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef i64 @_ZNSt3__114numeric_limitsIyE3maxB9nqe230101Ev() #4
  store i64 %call7, ptr %retval, align 8
  br label %return

if.end8:                                          ; preds = %if.end4
  %4 = load float, ptr %value.addr, align 4
  %conv = fptoui float %4 to i64
  store i64 %conv, ptr %retval, align 8
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %5 = load i64, ptr %retval, align 8
  ret i64 %5
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef signext i8 @_Z9ByteShiftRay(ptr noundef nonnull align 1 dereferenceable(1) %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %conv = sext i8 %1 to i32
  %2 = load i64, ptr %right.addr, align 8
  %and = and i64 %2, 7
  %sh_prom = trunc i64 %and to i32
  %shl = shl i32 %conv, %sh_prom
  %conv1 = trunc i32 %shl to i8
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv1, ptr %3, align 1
  ret i8 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z9ByteRightRhx(ptr noundef nonnull align 1 dereferenceable(1) %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %conv = zext i8 %1 to i32
  %2 = load i64, ptr %right.addr, align 8
  %and = and i64 %2, 7
  %sh_prom = trunc i64 %and to i32
  %shr = ashr i32 %conv, %sh_prom
  %conv1 = trunc i32 %shr to i8
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv1, ptr %3, align 1
  ret i8 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11SignedRightRia(ptr noundef nonnull align 4 dereferenceable(4) %left, i8 noundef signext %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %right, ptr %right.addr, align 1
  %0 = load i8, ptr %right.addr, align 1
  %conv = sext i8 %0 to i32
  %and = and i32 %conv, 31
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !7
  %2 = load i32, ptr %1, align 4
  %shr = ashr i32 %2, %and
  store i32 %shr, ptr %1, align 4
  ret i32 %shr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z9WordShiftRta(ptr noundef nonnull align 2 dereferenceable(2) %left, i8 noundef signext %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %right, ptr %right.addr, align 1
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  %1 = load i16, ptr %0, align 2
  %conv = zext i16 %1 to i32
  %2 = load i8, ptr %right.addr, align 1
  %conv1 = sext i8 %2 to i32
  %and = and i32 %conv1, 15
  %shl = shl i32 %conv, %and
  %conv2 = trunc i32 %shl to i16
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !6
  store i16 %conv2, ptr %3, align 2
  ret i16 %conv2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z9WideShiftRxh(ptr noundef nonnull align 8 dereferenceable(8) %left, i8 noundef zeroext %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i8, align 1
  store ptr %left, ptr %left.addr, align 8
  store i8 %right, ptr %right.addr, align 1
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  %1 = load i64, ptr %0, align 8
  %2 = load i8, ptr %right.addr, align 1
  %conv = zext i8 %2 to i32
  %and = and i32 %conv, 63
  %sh_prom = zext i32 %and to i64
  %shl = shl i64 %1, %sh_prom
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  store i64 %shl, ptr %3, align 8
  ret i64 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z9SizeShiftRmi(ptr noundef nonnull align 8 dereferenceable(8) %left, i32 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %and = and i32 %0, 63
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  %2 = load i64, ptr %1, align 8
  %sh_prom = zext i32 %and to i64
  %shl = shl i64 %2, %sh_prom
  store i64 %shl, ptr %1, align 8
  ret i64 %shl
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i64 @_Z15SignedSizeRightRly(ptr noundef nonnull align 8 dereferenceable(8) %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  %and = and i64 %0, 63
  %1 = load ptr, ptr %left.addr, align 8, !nonnull !5, !align !8
  %2 = load i64, ptr %1, align 8
  %shr = ashr i64 %2, %and
  store i64 %shr, ptr %1, align 8
  ret i64 %shr
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z11FixedBySizeRhm(ptr noundef nonnull align 1 dereferenceable(1) %left, i64 noundef %right) #0 {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8, !nonnull !5
  %1 = load i8, ptr %0, align 1
  %conv = zext i8 %1 to i32
  %2 = load i64, ptr %right.addr, align 8
  %and = and i64 %2, 7
  %sh_prom = trunc i64 %and to i32
  %shl = shl i32 %conv, %sh_prom
  %conv1 = trunc i32 %shl to i8
  %3 = load ptr, ptr %left.addr, align 8, !nonnull !5
  store i8 %conv1, ptr %3, align 1
  ret i8 %conv1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %__x) #0 {
entry:
  %__x.addr = alloca double, align 8
  store double %__x, ptr %__x.addr, align 8
  %0 = load double, ptr %__x.addr, align 8
  %1 = call i1 @llvm.is.fpclass.f64(double %0, /* (nan) */ i32 3)
  ret i1 %1
}

; Function Attrs: nounwind willreturn memory(none)
declare double @ldexp(double noundef, i32 noundef) #2

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__114numeric_limitsIiE6lowestB9nqe230101Ev() #0 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE6lowestB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__114numeric_limitsIiE3maxB9nqe230101Ev() #0 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE3maxB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i1 @llvm.is.fpclass.f64(double, i32 immarg) #3

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE6lowestB9nqe230101Ev() #0 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE3minB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE3minB9nqe230101Ev() #0 {
entry:
  ret i32 -2147483648
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE3maxB9nqe230101Ev() #0 {
entry:
  ret i32 2147483647
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101Ef(float noundef %__x) #0 {
entry:
  %__x.addr = alloca float, align 4
  store float %__x, ptr %__x.addr, align 4
  %0 = load float, ptr %__x.addr, align 4
  %1 = call i1 @llvm.is.fpclass.f32(float %0, /* (nan) */ i32 3)
  ret i1 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef float @_ZNSt3__16__math5ldexpB9nqe230101Efi(float noundef %__x, i32 noundef %__e) #0 {
entry:
  %__x.addr = alloca float, align 4
  %__e.addr = alloca i32, align 4
  store float %__x, ptr %__x.addr, align 4
  store i32 %__e, ptr %__e.addr, align 4
  %0 = load float, ptr %__x.addr, align 4
  %1 = load i32, ptr %__e.addr, align 4
  %2 = call float @llvm.ldexp.f32.i32(float %0, i32 %1)
  ret float %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__114numeric_limitsIyE6lowestB9nqe230101Ev() #0 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIyLb1EE6lowestB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__114numeric_limitsIyE3maxB9nqe230101Ev() #0 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIyLb1EE3maxB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i1 @llvm.is.fpclass.f32(float, i32 immarg) #3

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.ldexp.f32.i32(float, i32) #3

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIyLb1EE6lowestB9nqe230101Ev() #0 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIyLb1EE3minB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIyLb1EE3minB9nqe230101Ev() #0 {
entry:
  ret i64 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIyLb1EE3maxB9nqe230101Ev() #0 {
entry:
  ret i64 -1
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nounwind willreturn memory(none) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #4 = { nounwind }
attributes #5 = { nounwind willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 2}
!7 = !{i64 4}
!8 = !{i64 8}
