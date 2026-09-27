%struct.Value = type { i32 }

define noundef nonnull align 4 dereferenceable(4) ptr @Choose(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
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

define noundef i32 @Form(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca i8, align 1
  %source.addr = alloca ptr, align 8
  %result = alloca %struct.Value, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %source, ptr %source.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  call void @llvm.memset.p0.i64(ptr align 4 %result, i8 0, i64 4, i1 false)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %1 = load ptr, ptr %source.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %result, ptr align 4 %1, i64 4, i1 false)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %number = getelementptr inbounds nuw %struct.Value, ptr %result, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @Read(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Temporary() {
entry:
  %.result = alloca i32, align 4
  %temporary = alloca %struct.Value, align 4
  call void @llvm.memset.p0.i64(ptr align 4 %temporary, i8 0, i64 4, i1 false)
  %call = call noundef i32 @Read(ptr noundef nonnull align 4 dereferenceable(4) %temporary)
  store i32 %call, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define void @Discard(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %flag.addr = alloca i8, align 1
  %source.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %source, ptr %source.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  %1 = load ptr, ptr %source.addr, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
