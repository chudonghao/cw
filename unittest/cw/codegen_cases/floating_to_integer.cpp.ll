; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names floating_to_integer.cpp -o -
; ModuleID = 'floating_to_integer.cpp'
source_filename = "floating_to_integer.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef signext i8 @_Z7Signed8d(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef signext i8 @_Z8SaturateIadET_T0_(double noundef %0)
  ret i8 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef signext i8 @_Z8SaturateIadET_T0_(double noundef %value) #1 {
entry:
  %retval = alloca i8, align 1
  %value.addr = alloca double, align 8
  %upper = alloca double, align 8
  %lower = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i8 0, ptr %retval, align 1
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call double @ldexp(double noundef 1.000000e+00, i32 noundef 7) #5
  store double %call1, ptr %upper, align 8
  %1 = load double, ptr %upper, align 8
  %fneg = fneg double %1
  store double %fneg, ptr %lower, align 8
  %2 = load double, ptr %value.addr, align 8
  %3 = load double, ptr %lower, align 8
  %cmp = fcmp ole double %2, %3
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef signext i8 @_ZNSt3__114numeric_limitsIaE6lowestB9nqe230101Ev() #4
  store i8 %call3, ptr %retval, align 1
  br label %return

if.end4:                                          ; preds = %if.end
  %4 = load double, ptr %value.addr, align 8
  %5 = load double, ptr %upper, align 8
  %cmp5 = fcmp oge double %4, %5
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef signext i8 @_ZNSt3__114numeric_limitsIaE3maxB9nqe230101Ev() #4
  store i8 %call7, ptr %retval, align 1
  br label %return

if.end8:                                          ; preds = %if.end4
  %6 = load double, ptr %value.addr, align 8
  %conv = fptosi double %6 to i8
  store i8 %conv, ptr %retval, align 1
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %7 = load i8, ptr %retval, align 1
  ret i8 %7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z9Unsigned8d(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i8 @_Z8SaturateIhdET_T0_(double noundef %0)
  ret i8 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef zeroext i8 @_Z8SaturateIhdET_T0_(double noundef %value) #1 {
entry:
  %retval = alloca i8, align 1
  %value.addr = alloca double, align 8
  %upper = alloca double, align 8
  %lower = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i8 0, ptr %retval, align 1
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call double @ldexp(double noundef 1.000000e+00, i32 noundef 8) #5
  store double %call1, ptr %upper, align 8
  store double 0.000000e+00, ptr %lower, align 8
  %1 = load double, ptr %value.addr, align 8
  %cmp = fcmp ole double %1, 0.000000e+00
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef zeroext i8 @_ZNSt3__114numeric_limitsIhE6lowestB9nqe230101Ev() #4
  store i8 %call3, ptr %retval, align 1
  br label %return

if.end4:                                          ; preds = %if.end
  %2 = load double, ptr %value.addr, align 8
  %3 = load double, ptr %upper, align 8
  %cmp5 = fcmp oge double %2, %3
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef zeroext i8 @_ZNSt3__114numeric_limitsIhE3maxB9nqe230101Ev() #4
  store i8 %call7, ptr %retval, align 1
  br label %return

if.end8:                                          ; preds = %if.end4
  %4 = load double, ptr %value.addr, align 8
  %conv = fptoui double %4 to i8
  store i8 %conv, ptr %retval, align 1
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %5 = load i8, ptr %retval, align 1
  ret i8 %5
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef signext i16 @_Z8Signed16d(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef signext i16 @_Z8SaturateIsdET_T0_(double noundef %0)
  ret i16 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef signext i16 @_Z8SaturateIsdET_T0_(double noundef %value) #1 {
entry:
  %retval = alloca i16, align 2
  %value.addr = alloca double, align 8
  %upper = alloca double, align 8
  %lower = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i16 0, ptr %retval, align 2
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call double @ldexp(double noundef 1.000000e+00, i32 noundef 15) #5
  store double %call1, ptr %upper, align 8
  %1 = load double, ptr %upper, align 8
  %fneg = fneg double %1
  store double %fneg, ptr %lower, align 8
  %2 = load double, ptr %value.addr, align 8
  %3 = load double, ptr %lower, align 8
  %cmp = fcmp ole double %2, %3
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef signext i16 @_ZNSt3__114numeric_limitsIsE6lowestB9nqe230101Ev() #4
  store i16 %call3, ptr %retval, align 2
  br label %return

if.end4:                                          ; preds = %if.end
  %4 = load double, ptr %value.addr, align 8
  %5 = load double, ptr %upper, align 8
  %cmp5 = fcmp oge double %4, %5
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef signext i16 @_ZNSt3__114numeric_limitsIsE3maxB9nqe230101Ev() #4
  store i16 %call7, ptr %retval, align 2
  br label %return

if.end8:                                          ; preds = %if.end4
  %6 = load double, ptr %value.addr, align 8
  %conv = fptosi double %6 to i16
  store i16 %conv, ptr %retval, align 2
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %7 = load i16, ptr %retval, align 2
  ret i16 %7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i16 @_Z10Unsigned16d(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i16 @_Z8SaturateItdET_T0_(double noundef %0)
  ret i16 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef zeroext i16 @_Z8SaturateItdET_T0_(double noundef %value) #1 {
entry:
  %retval = alloca i16, align 2
  %value.addr = alloca double, align 8
  %upper = alloca double, align 8
  %lower = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i16 0, ptr %retval, align 2
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call double @ldexp(double noundef 1.000000e+00, i32 noundef 16) #5
  store double %call1, ptr %upper, align 8
  store double 0.000000e+00, ptr %lower, align 8
  %1 = load double, ptr %value.addr, align 8
  %cmp = fcmp ole double %1, 0.000000e+00
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef zeroext i16 @_ZNSt3__114numeric_limitsItE6lowestB9nqe230101Ev() #4
  store i16 %call3, ptr %retval, align 2
  br label %return

if.end4:                                          ; preds = %if.end
  %2 = load double, ptr %value.addr, align 8
  %3 = load double, ptr %upper, align 8
  %cmp5 = fcmp oge double %2, %3
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef zeroext i16 @_ZNSt3__114numeric_limitsItE3maxB9nqe230101Ev() #4
  store i16 %call7, ptr %retval, align 2
  br label %return

if.end8:                                          ; preds = %if.end4
  %4 = load double, ptr %value.addr, align 8
  %conv = fptoui double %4 to i16
  store i16 %conv, ptr %retval, align 2
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %5 = load i16, ptr %retval, align 2
  ret i16 %5
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8Signed32d(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef i32 @_Z8SaturateIidET_T0_(double noundef %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_Z8SaturateIidET_T0_(double noundef %value) #1 {
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
define noundef i32 @_Z10Unsigned32d(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef i32 @_Z8SaturateIjdET_T0_(double noundef %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_Z8SaturateIjdET_T0_(double noundef %value) #1 {
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
  %call1 = call double @ldexp(double noundef 1.000000e+00, i32 noundef 32) #5
  store double %call1, ptr %upper, align 8
  store double 0.000000e+00, ptr %lower, align 8
  %1 = load double, ptr %value.addr, align 8
  %cmp = fcmp ole double %1, 0.000000e+00
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef i32 @_ZNSt3__114numeric_limitsIjE6lowestB9nqe230101Ev() #4
  store i32 %call3, ptr %retval, align 4
  br label %return

if.end4:                                          ; preds = %if.end
  %2 = load double, ptr %value.addr, align 8
  %3 = load double, ptr %upper, align 8
  %cmp5 = fcmp oge double %2, %3
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef i32 @_ZNSt3__114numeric_limitsIjE3maxB9nqe230101Ev() #4
  store i32 %call7, ptr %retval, align 4
  br label %return

if.end8:                                          ; preds = %if.end4
  %4 = load double, ptr %value.addr, align 8
  %conv = fptoui double %4 to i32
  store i32 %conv, ptr %retval, align 4
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %5 = load i32, ptr %retval, align 4
  ret i32 %5
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z8Signed64d(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef i64 @_Z8SaturateIldET_T0_(double noundef %0)
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i64 @_Z8SaturateIldET_T0_(double noundef %value) #1 {
entry:
  %retval = alloca i64, align 8
  %value.addr = alloca double, align 8
  %upper = alloca double, align 8
  %lower = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i64 0, ptr %retval, align 8
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call double @ldexp(double noundef 1.000000e+00, i32 noundef 63) #5
  store double %call1, ptr %upper, align 8
  %1 = load double, ptr %upper, align 8
  %fneg = fneg double %1
  store double %fneg, ptr %lower, align 8
  %2 = load double, ptr %value.addr, align 8
  %3 = load double, ptr %lower, align 8
  %cmp = fcmp ole double %2, %3
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef i64 @_ZNSt3__114numeric_limitsIlE6lowestB9nqe230101Ev() #4
  store i64 %call3, ptr %retval, align 8
  br label %return

if.end4:                                          ; preds = %if.end
  %4 = load double, ptr %value.addr, align 8
  %5 = load double, ptr %upper, align 8
  %cmp5 = fcmp oge double %4, %5
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef i64 @_ZNSt3__114numeric_limitsIlE3maxB9nqe230101Ev() #4
  store i64 %call7, ptr %retval, align 8
  br label %return

if.end8:                                          ; preds = %if.end4
  %6 = load double, ptr %value.addr, align 8
  %conv = fptosi double %6 to i64
  store i64 %conv, ptr %retval, align 8
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %7 = load i64, ptr %retval, align 8
  ret i64 %7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z10Unsigned64d(double noundef %value) #0 {
entry:
  %value.addr = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef i64 @_Z8SaturateImdET_T0_(double noundef %0)
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i64 @_Z8SaturateImdET_T0_(double noundef %value) #1 {
entry:
  %retval = alloca i64, align 8
  %value.addr = alloca double, align 8
  %upper = alloca double, align 8
  %lower = alloca double, align 8
  store double %value, ptr %value.addr, align 8
  %0 = load double, ptr %value.addr, align 8
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i64 0, ptr %retval, align 8
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call double @ldexp(double noundef 1.000000e+00, i32 noundef 64) #5
  store double %call1, ptr %upper, align 8
  store double 0.000000e+00, ptr %lower, align 8
  %1 = load double, ptr %value.addr, align 8
  %cmp = fcmp ole double %1, 0.000000e+00
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef i64 @_ZNSt3__114numeric_limitsImE6lowestB9nqe230101Ev() #4
  store i64 %call3, ptr %retval, align 8
  br label %return

if.end4:                                          ; preds = %if.end
  %2 = load double, ptr %value.addr, align 8
  %3 = load double, ptr %upper, align 8
  %cmp5 = fcmp oge double %2, %3
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef i64 @_ZNSt3__114numeric_limitsImE3maxB9nqe230101Ev() #4
  store i64 %call7, ptr %retval, align 8
  br label %return

if.end8:                                          ; preds = %if.end4
  %4 = load double, ptr %value.addr, align 8
  %conv = fptoui double %4 to i64
  store i64 %conv, ptr %retval, align 8
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %5 = load i64, ptr %retval, align 8
  ret i64 %5
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z12SignedSinglef(float noundef %value) #0 {
entry:
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %call = call noundef i32 @_Z8SaturateIifET_T0_(float noundef %0)
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i32 @_Z8SaturateIifET_T0_(float noundef %value) #1 {
entry:
  %retval = alloca i32, align 4
  %value.addr = alloca float, align 4
  %upper = alloca float, align 4
  %lower = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %call = call noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101Ef(float noundef %0) #4
  br i1 %call, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 0, ptr %retval, align 4
  br label %return

if.end:                                           ; preds = %entry
  %call1 = call noundef float @_ZNSt3__16__math5ldexpB9nqe230101Efi(float noundef 1.000000e+00, i32 noundef 31) #4
  store float %call1, ptr %upper, align 4
  %1 = load float, ptr %upper, align 4
  %fneg = fneg float %1
  store float %fneg, ptr %lower, align 4
  %2 = load float, ptr %value.addr, align 4
  %3 = load float, ptr %lower, align 4
  %cmp = fcmp ole float %2, %3
  br i1 %cmp, label %if.then2, label %if.end4

if.then2:                                         ; preds = %if.end
  %call3 = call noundef i32 @_ZNSt3__114numeric_limitsIiE6lowestB9nqe230101Ev() #4
  store i32 %call3, ptr %retval, align 4
  br label %return

if.end4:                                          ; preds = %if.end
  %4 = load float, ptr %value.addr, align 4
  %5 = load float, ptr %upper, align 4
  %cmp5 = fcmp oge float %4, %5
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef i32 @_ZNSt3__114numeric_limitsIiE3maxB9nqe230101Ev() #4
  store i32 %call7, ptr %retval, align 4
  br label %return

if.end8:                                          ; preds = %if.end4
  %6 = load float, ptr %value.addr, align 4
  %conv = fptosi float %6 to i32
  store i32 %conv, ptr %retval, align 4
  br label %return

return:                                           ; preds = %if.end8, %if.then6, %if.then2, %if.then
  %7 = load i32, ptr %retval, align 4
  ret i32 %7
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z14UnsignedSinglef(float noundef %value) #0 {
entry:
  %value.addr = alloca float, align 4
  store float %value, ptr %value.addr, align 4
  %0 = load float, ptr %value.addr, align 4
  %call = call noundef i64 @_Z8SaturateImfET_T0_(float noundef %0)
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef i64 @_Z8SaturateImfET_T0_(float noundef %value) #1 {
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
  %call3 = call noundef i64 @_ZNSt3__114numeric_limitsImE6lowestB9nqe230101Ev() #4
  store i64 %call3, ptr %retval, align 8
  br label %return

if.end4:                                          ; preds = %if.end
  %2 = load float, ptr %value.addr, align 4
  %3 = load float, ptr %upper, align 4
  %cmp5 = fcmp oge float %2, %3
  br i1 %cmp5, label %if.then6, label %if.end8

if.then6:                                         ; preds = %if.end4
  %call7 = call noundef i64 @_ZNSt3__114numeric_limitsImE3maxB9nqe230101Ev() #4
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

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z8Fractionv() #0 {
entry:
  %call = call noundef i32 @_Z8SaturateIidET_T0_(double noundef -3.900000e+00)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z9ClampBytev() #0 {
entry:
  %call = call noundef zeroext i8 @_Z8SaturateIhdET_T0_(double noundef 3.000000e+02)
  ret i8 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef signext i8 @_Z15ClampSignedBytev() #0 {
entry:
  %call = call noundef signext i8 @_Z8SaturateIadET_T0_(double noundef 1.280000e+02)
  ret i8 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z13ClampNegativev() #0 {
entry:
  %call = call noundef zeroext i8 @_Z8SaturateIhdET_T0_(double noundef -5.000000e-01)
  ret i8 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z9NaNToZerov() #0 {
entry:
  %call = call noundef i32 @_Z8SaturateIidET_T0_(double noundef +qnan)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z16PositiveInfinityv() #0 {
entry:
  %call = call noundef i64 @_Z8SaturateIldET_T0_(double noundef +inf)
  ret i64 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z16NegativeInfinityv() #0 {
entry:
  %call = call noundef i64 @_Z8SaturateIldET_T0_(double noundef -inf)
  ret i64 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z16UnsignedInfinityv() #0 {
entry:
  %call = call noundef i64 @_Z8SaturateImdET_T0_(double noundef +inf)
  ret i64 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z24UnsignedNegativeInfinityv() #0 {
entry:
  %call = call noundef i64 @_Z8SaturateImdET_T0_(double noundef -inf)
  ret i64 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z19SignedUpperBoundaryv() #0 {
entry:
  %call = call noundef i64 @_Z8SaturateIldET_T0_(double noundef f0x43E0000000000000)
  ret i64 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i64 @_Z21UnsignedUpperBoundaryv() #0 {
entry:
  %call = call noundef i64 @_Z8SaturateImdET_T0_(double noundef f0x43F0000000000000)
  ret i64 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z12NegativeZerov() #0 {
entry:
  %call = call noundef i32 @_Z8SaturateIidET_T0_(double noundef -0.000000e+00)
  ret i32 %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z10ViaIntegerv() #0 {
entry:
  %value = alloca i32, align 4
  %call = call noundef i32 @_Z8SaturateIidET_T0_(double noundef 3.000000e+02)
  store i32 %call, ptr %value, align 4
  %0 = load i32, ptr %value, align 4
  %conv = trunc i32 %0 to i8
  ret i8 %conv
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101EUa9enable_ifILb1EEd(double noundef %__x) #1 {
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
define linkonce_odr hidden noundef signext i8 @_ZNSt3__114numeric_limitsIaE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef signext i8 @_ZNSt3__123__libcpp_numeric_limitsIaLb1EE6lowestB9nqe230101Ev() #4
  ret i8 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i8 @_ZNSt3__114numeric_limitsIaE3maxB9nqe230101Ev() #1 {
entry:
  %call = call noundef signext i8 @_ZNSt3__123__libcpp_numeric_limitsIaLb1EE3maxB9nqe230101Ev() #4
  ret i8 %call
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i1 @llvm.is.fpclass.f64(double, i32 immarg) #3

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i8 @_ZNSt3__123__libcpp_numeric_limitsIaLb1EE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef signext i8 @_ZNSt3__123__libcpp_numeric_limitsIaLb1EE3minB9nqe230101Ev() #4
  ret i8 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i8 @_ZNSt3__123__libcpp_numeric_limitsIaLb1EE3minB9nqe230101Ev() #1 {
entry:
  ret i8 -128
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i8 @_ZNSt3__123__libcpp_numeric_limitsIaLb1EE3maxB9nqe230101Ev() #1 {
entry:
  ret i8 127
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i8 @_ZNSt3__114numeric_limitsIhE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef zeroext i8 @_ZNSt3__123__libcpp_numeric_limitsIhLb1EE6lowestB9nqe230101Ev() #4
  ret i8 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i8 @_ZNSt3__114numeric_limitsIhE3maxB9nqe230101Ev() #1 {
entry:
  %call = call noundef zeroext i8 @_ZNSt3__123__libcpp_numeric_limitsIhLb1EE3maxB9nqe230101Ev() #4
  ret i8 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i8 @_ZNSt3__123__libcpp_numeric_limitsIhLb1EE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef zeroext i8 @_ZNSt3__123__libcpp_numeric_limitsIhLb1EE3minB9nqe230101Ev() #4
  ret i8 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i8 @_ZNSt3__123__libcpp_numeric_limitsIhLb1EE3minB9nqe230101Ev() #1 {
entry:
  ret i8 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i8 @_ZNSt3__123__libcpp_numeric_limitsIhLb1EE3maxB9nqe230101Ev() #1 {
entry:
  ret i8 -1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i16 @_ZNSt3__114numeric_limitsIsE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef signext i16 @_ZNSt3__123__libcpp_numeric_limitsIsLb1EE6lowestB9nqe230101Ev() #4
  ret i16 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i16 @_ZNSt3__114numeric_limitsIsE3maxB9nqe230101Ev() #1 {
entry:
  %call = call noundef signext i16 @_ZNSt3__123__libcpp_numeric_limitsIsLb1EE3maxB9nqe230101Ev() #4
  ret i16 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i16 @_ZNSt3__123__libcpp_numeric_limitsIsLb1EE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef signext i16 @_ZNSt3__123__libcpp_numeric_limitsIsLb1EE3minB9nqe230101Ev() #4
  ret i16 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i16 @_ZNSt3__123__libcpp_numeric_limitsIsLb1EE3minB9nqe230101Ev() #1 {
entry:
  ret i16 -32768
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef signext i16 @_ZNSt3__123__libcpp_numeric_limitsIsLb1EE3maxB9nqe230101Ev() #1 {
entry:
  ret i16 32767
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i16 @_ZNSt3__114numeric_limitsItE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef zeroext i16 @_ZNSt3__123__libcpp_numeric_limitsItLb1EE6lowestB9nqe230101Ev() #4
  ret i16 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i16 @_ZNSt3__114numeric_limitsItE3maxB9nqe230101Ev() #1 {
entry:
  %call = call noundef zeroext i16 @_ZNSt3__123__libcpp_numeric_limitsItLb1EE3maxB9nqe230101Ev() #4
  ret i16 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i16 @_ZNSt3__123__libcpp_numeric_limitsItLb1EE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef zeroext i16 @_ZNSt3__123__libcpp_numeric_limitsItLb1EE3minB9nqe230101Ev() #4
  ret i16 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i16 @_ZNSt3__123__libcpp_numeric_limitsItLb1EE3minB9nqe230101Ev() #1 {
entry:
  ret i16 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i16 @_ZNSt3__123__libcpp_numeric_limitsItLb1EE3maxB9nqe230101Ev() #1 {
entry:
  ret i16 -1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__114numeric_limitsIiE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE6lowestB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__114numeric_limitsIiE3maxB9nqe230101Ev() #1 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE3maxB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE3minB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE3minB9nqe230101Ev() #1 {
entry:
  ret i32 -2147483648
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIiLb1EE3maxB9nqe230101Ev() #1 {
entry:
  ret i32 2147483647
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__114numeric_limitsIjE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIjLb1EE6lowestB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__114numeric_limitsIjE3maxB9nqe230101Ev() #1 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIjLb1EE3maxB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIjLb1EE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIjLb1EE3minB9nqe230101Ev() #4
  ret i32 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIjLb1EE3minB9nqe230101Ev() #1 {
entry:
  ret i32 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i32 @_ZNSt3__123__libcpp_numeric_limitsIjLb1EE3maxB9nqe230101Ev() #1 {
entry:
  ret i32 -1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__114numeric_limitsIlE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIlLb1EE6lowestB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__114numeric_limitsIlE3maxB9nqe230101Ev() #1 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIlLb1EE3maxB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIlLb1EE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIlLb1EE3minB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIlLb1EE3minB9nqe230101Ev() #1 {
entry:
  ret i64 -9223372036854775808
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsIlLb1EE3maxB9nqe230101Ev() #1 {
entry:
  ret i64 9223372036854775807
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__114numeric_limitsImE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsImLb1EE6lowestB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__114numeric_limitsImE3maxB9nqe230101Ev() #1 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsImLb1EE3maxB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsImLb1EE6lowestB9nqe230101Ev() #1 {
entry:
  %call = call noundef i64 @_ZNSt3__123__libcpp_numeric_limitsImLb1EE3minB9nqe230101Ev() #4
  ret i64 %call
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsImLb1EE3minB9nqe230101Ev() #1 {
entry:
  ret i64 0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef i64 @_ZNSt3__123__libcpp_numeric_limitsImLb1EE3maxB9nqe230101Ev() #1 {
entry:
  ret i64 -1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef zeroext i1 @_ZNSt3__16__math5isnanB9nqe230101Ef(float noundef %__x) #1 {
entry:
  %__x.addr = alloca float, align 4
  store float %__x, ptr %__x.addr, align 4
  %0 = load float, ptr %__x.addr, align 4
  %1 = call i1 @llvm.is.fpclass.f32(float %0, /* (nan) */ i32 3)
  ret i1 %1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr hidden noundef float @_ZNSt3__16__math5ldexpB9nqe230101Efi(float noundef %__x, i32 noundef %__e) #1 {
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

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i1 @llvm.is.fpclass.f32(float, i32 immarg) #3

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.ldexp.f32.i32(float, i32) #3

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
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
