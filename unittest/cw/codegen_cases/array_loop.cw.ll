define noundef i32 @Sum(ptr noundef nonnull align 4 dereferenceable(8) %values, i64 noundef %begin, i64 noundef %end, i64 noundef %step) {
entry:
  %.result = alloca i32, align 4
  %values.addr = alloca ptr, align 8
  %begin.addr = alloca i64, align 8
  %end.addr = alloca i64, align 8
  %step.addr = alloca i64, align 8
  %total = alloca i32, align 4
  %index = alloca i64, align 8
  store ptr %values, ptr %values.addr, align 8
  store i64 %begin, ptr %begin.addr, align 8
  store i64 %end, ptr %end.addr, align 8
  store i64 %step, ptr %step.addr, align 8
  store i32 0, ptr %total, align 4
  %0 = load i64, ptr %begin.addr, align 8
  store i64 %0, ptr %index, align 8
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %1 = load i64, ptr %index, align 8
  %2 = load i64, ptr %end.addr, align 8
  %cmp = icmp ult i64 %1, %2
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %3 = load i32, ptr %total, align 4
  %4 = load ptr, ptr %values.addr, align 8
  %5 = load i64, ptr %index, align 8
  %element = getelementptr [2 x i32], ptr %4, i64 0, i64 %5
  %6 = load i32, ptr %element, align 4
  %add = add i32 %3, %6
  store i32 %add, ptr %total, align 4
  %7 = load i64, ptr %index, align 8
  %8 = load i64, ptr %step.addr, align 8
  %add1 = add i64 %7, %8
  store i64 %add1, ptr %index, align 8
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %9 = load i32, ptr %total, align 4
  store i32 %9, ptr %.result, align 4
  %10 = load i32, ptr %.result, align 4
  ret i32 %10
}
