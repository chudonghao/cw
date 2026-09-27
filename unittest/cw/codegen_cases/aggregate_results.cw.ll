%struct.Value = type { i32 }

define i32 @Make(i32 noundef %value) {
entry:
  %result = alloca %struct.Value, align 4
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %number = getelementptr inbounds nuw %struct.Value, ptr %result, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %number, align 4
  %1 = load i32, ptr %result, align 4
  ret i32 %1
}

define i32 @Choose(i1 noundef zeroext %flag, i32 noundef %left, i32 noundef %right) {
entry:
  %.result = alloca %struct.Value, align 4
  %flag.addr = alloca i8, align 1
  %left.addr = alloca i32, align 4
  %right.addr = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 %left, ptr %left.addr, align 4
  store i32 %right, ptr %right.addr, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i32, ptr %left.addr, align 4
  %call = call i32 @Make(i32 noundef %1)
  store i32 %call, ptr %.result, align 4
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load i32, ptr %right.addr, align 4
  %call1 = call i32 @Make(i32 noundef %2)
  store i32 %call1, ptr %.result, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
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

define noundef i32 @Bind(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  %temporary = alloca %struct.Value, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call i32 @Make(i32 noundef %0)
  store i32 %call, ptr %temporary, align 4
  %call1 = call noundef i32 @Read(ptr noundef nonnull align 4 dereferenceable(4) %temporary)
  store i32 %call1, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @Member(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  %temporary = alloca %struct.Value, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call i32 @Make(i32 noundef %0)
  store i32 %call, ptr %temporary, align 4
  %number = getelementptr inbounds nuw %struct.Value, ptr %temporary, i32 0, i32 0
  %1 = load i32, ptr %number, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define void @Discard(i1 noundef zeroext %flag, i32 noundef %value) {
entry:
  %flag.addr = alloca i8, align 1
  %value.addr = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i32 %value, ptr %value.addr, align 4
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i32, ptr %value.addr, align 4
  %call = call i32 @Make(i32 noundef %1)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %call1 = call i32 @Make(i32 noundef 0)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  ret void
}

define noundef nonnull align 4 dereferenceable(4) ptr @Target(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  store i32 99, ptr %0, align 4
  %1 = load ptr, ptr %target.addr, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define void @Assign(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %temporary = alloca %struct.Value, align 4
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load i32, ptr %0, align 4
  %call = call i32 @Make(i32 noundef %1)
  store i32 %call, ptr %temporary, align 4
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load ptr, ptr %source.addr, align 8
  %call1 = call noundef nonnull align 4 dereferenceable(4) ptr @Target(ptr noundef nonnull align 4 dereferenceable(4) %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call1, ptr align 4 %temporary, i64 4, i1 false)
  ret void
}

define noundef i32 @Take(i64 %value.coerce) {
entry:
  %.result = alloca i32, align 4
  %value = alloca %struct.Value, align 4
  %coerce = trunc i64 %value.coerce to i32
  store i32 %coerce, ptr %value, align 4
  %number = getelementptr inbounds nuw %struct.Value, ptr %value, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @Receiver(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.Value, align 4
  %coerce = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %argument, ptr align 4 %0, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 4 %argument, i64 4, i1 false)
  %1 = load i64, ptr %coerce, align 8
  %call = call noundef i32 @Take(i64 %1)
  store i32 %call, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Pass(i32 noundef %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca i32, align 4
  %argument = alloca %struct.Value, align 4
  %coerce = alloca i64, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call i32 @Make(i32 noundef %0)
  store i32 %call, ptr %argument, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 4 %argument, i64 4, i1 false)
  %1 = load i64, ptr %coerce, align 8
  %call1 = call noundef i32 @Take(i64 %1)
  store i32 %call1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define i32 @Local(i32 noundef %value) {
entry:
  %.result = alloca %struct.Value, align 4
  %value.addr = alloca i32, align 4
  %object = alloca %struct.Value, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  %call = call i32 @Make(i32 noundef %0)
  store i32 %call, ptr %object, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %object, i64 4, i1 false)
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
