define noundef nonnull align 4 dereferenceable(8) ptr @Choose(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(8) %left, ptr noundef nonnull align 4 dereferenceable(8) %right) {
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

define noundef i32 @Value(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(8) %source, i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca i8, align 1
  %source.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %values = alloca [2 x i32], align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %source, ptr %source.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %source.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %values, ptr align 4 %1, i64 8, i1 false)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %element = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 0
  store i32 7, ptr %element, align 4
  %element1 = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 1
  store i32 8, ptr %element1, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %2 = load i64, ptr %index.addr, align 8
  %element2 = getelementptr [2 x i32], ptr %values, i64 0, i64 %2
  %3 = load i32, ptr %element2, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i32 @Temporary(i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %index.addr = alloca i64, align 8
  %temporary = alloca [2 x i32], align 4
  store i64 %index, ptr %index.addr, align 8
  %element = getelementptr inbounds nuw [2 x i32], ptr %temporary, i64 0, i64 0
  store i32 5, ptr %element, align 4
  %element1 = getelementptr inbounds nuw [2 x i32], ptr %temporary, i64 0, i64 1
  store i32 7, ptr %element1, align 4
  %0 = load i64, ptr %index.addr, align 8
  %element2 = getelementptr [2 x i32], ptr %temporary, i64 0, i64 %0
  %1 = load i32, ptr %element2, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
