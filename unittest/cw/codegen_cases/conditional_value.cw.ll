define noundef i32 @ConditionalValue(i1 noundef zeroext %flag, i1 noundef zeroext %other, i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca i8, align 1
  %other.addr = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %other to i8
  store i8 %storedv1, ptr %other.addr, align 1
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i8, ptr %other.addr, align 1
  %loadedv5 = icmp ne i8 %1, 0
  br i1 %loadedv5, label %cond.true2, label %cond.false3

cond.true2:                                       ; preds = %cond.true
  %2 = load i32, ptr %left.addr, align 4
  br label %cond.end4

cond.false3:                                      ; preds = %cond.true
  br label %cond.end4

cond.end4:                                        ; preds = %cond.false3, %cond.true2
  %cond = phi i32 [ %2, %cond.true2 ], [ 7, %cond.false3 ]
  br label %cond.end

cond.false:                                       ; preds = %entry
  %3 = load i8, ptr %other.addr, align 1
  %loadedv9 = icmp ne i8 %3, 0
  br i1 %loadedv9, label %cond.true6, label %cond.false7

cond.true6:                                       ; preds = %cond.false
  br label %cond.end8

cond.false7:                                      ; preds = %cond.false
  %4 = load i32, ptr %right.addr, align 4
  br label %cond.end8

cond.end8:                                        ; preds = %cond.false7, %cond.true6
  %cond10 = phi i32 [ 11, %cond.true6 ], [ %4, %cond.false7 ]
  br label %cond.end

cond.end:                                         ; preds = %cond.end8, %cond.end4
  %cond11 = phi i32 [ %cond, %cond.end4 ], [ %cond10, %cond.end8 ]
  store i32 %cond11, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}
