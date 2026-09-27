@.str = private constant [3 x i8] c"yes", align 1
@.str.1 = private constant [3 x i8] c"no!", align 1

define noundef nonnull align 1 dereferenceable(3) ptr @Choose(i1 noundef zeroext %flag) {
entry:
  %.result = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ @.str, %cond.true ], [ @.str.1, %cond.false ]
  store ptr %cond, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef zeroext i8 @ReadChoice(i1 noundef zeroext %flag, i64 noundef %index) {
entry:
  %.result = alloca i8, align 1
  %flag.addr = alloca i8, align 1
  %index.addr = alloca i64, align 8
  %text = alloca [3 x i8], align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i64 %index, ptr %index.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ @.str, %cond.true ], [ @.str.1, %cond.false ]
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %text, ptr align 1 %cond, i64 3, i1 false)
  %1 = load i64, ptr %index.addr, align 8
  %element = getelementptr [3 x i8], ptr %text, i64 0, i64 %1
  %2 = load i8, ptr %element, align 1
  store i8 %2, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  ret i8 %3
}

define noundef zeroext i8 @WithValue(i1 noundef zeroext %flag, i64 noundef %index) {
entry:
  %.result = alloca i8, align 1
  %flag.addr = alloca i8, align 1
  %index.addr = alloca i64, align 8
  %text = alloca [3 x i8], align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i64 %index, ptr %index.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %text, ptr align 1 @.str, i64 3, i1 false)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %element = getelementptr inbounds nuw [3 x i8], ptr %text, i64 0, i64 0
  store i8 110, ptr %element, align 1
  %element1 = getelementptr inbounds nuw [3 x i8], ptr %text, i64 0, i64 1
  store i8 111, ptr %element1, align 1
  %element2 = getelementptr inbounds nuw [3 x i8], ptr %text, i64 0, i64 2
  store i8 33, ptr %element2, align 1
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %1 = load i64, ptr %index.addr, align 8
  %element3 = getelementptr [3 x i8], ptr %text, i64 0, i64 %1
  %2 = load i8, ptr %element3, align 1
  store i8 %2, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  ret i8 %3
}

define noundef nonnull align 1 dereferenceable(3) ptr @Touch(ptr noundef nonnull align 4 dereferenceable(4) %count) {
entry:
  %.result = alloca ptr, align 8
  %count.addr = alloca ptr, align 8
  store ptr %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %count.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %count.addr, align 8
  store i32 %add, ptr %2, align 4
  store ptr @.str.1, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define void @Discard(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %count) {
entry:
  %flag.addr = alloca i8, align 1
  %count.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %count, ptr %count.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  %1 = load ptr, ptr %count.addr, align 8
  %call = call noundef nonnull align 1 dereferenceable(3) ptr @Touch(ptr noundef nonnull align 4 dereferenceable(4) %1)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
