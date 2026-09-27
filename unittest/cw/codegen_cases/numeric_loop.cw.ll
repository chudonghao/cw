define noundef i32 @NumericLoop(i32 noundef %limit) {
entry:
  %.result = alloca i32, align 4
  %limit.addr = alloca i32, align 4
  %sum = alloca i32, align 4
  %index = alloca i32, align 4
  store i32 %limit, ptr %limit.addr, align 4
  store i32 0, ptr %sum, align 4
  store i32 0, ptr %index, align 4
  br label %while.cond

while.cond:                                       ; preds = %if.end, %entry
  %0 = load i32, ptr %index, align 4
  %1 = load i32, ptr %limit.addr, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %2 = load i32, ptr %index, align 4
  %rem = srem i32 %2, 2
  %cmp1 = icmp eq i32 %rem, 0
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  %3 = load i32, ptr %sum, align 4
  %4 = load i32, ptr %index, align 4
  %add = add i32 %3, %4
  store i32 %add, ptr %sum, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %while.body
  %5 = load i32, ptr %index, align 4
  %add2 = add i32 %5, 1
  store i32 %add2, ptr %index, align 4
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %6 = load i32, ptr %sum, align 4
  store i32 %6, ptr %.result, align 4
  %7 = load i32, ptr %.result, align 4
  ret i32 %7
}
