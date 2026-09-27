define noundef nonnull align 4 dereferenceable(8) ptr @Change(ptr noundef nonnull align 4 dereferenceable(8) %source, ptr noundef nonnull align 4 dereferenceable(8) %target, i64 noundef %index) {
entry:
  %.result = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load i64, ptr %index.addr, align 8
  %element = getelementptr [2 x i32], ptr %0, i64 0, i64 %1
  store i32 9, ptr %element, align 4
  %2 = load ptr, ptr %target.addr, align 8
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define void @Existing(ptr noundef nonnull align 4 dereferenceable(8) %source, ptr noundef nonnull align 4 dereferenceable(8) %target, i64 noundef %index) {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %source.addr, align 8
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load i64, ptr %index.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @Change(ptr noundef nonnull align 4 dereferenceable(8) %1, ptr noundef nonnull align 4 dereferenceable(8) %2, i64 noundef %3)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call, ptr align 4 %0, i64 8, i1 false)
  ret void
}

define void @Formed(ptr noundef nonnull align 4 dereferenceable(8) %source, ptr noundef nonnull align 4 dereferenceable(8) %target, i64 noundef %index) {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %temporary = alloca [2 x i32], align 4
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %element = getelementptr inbounds nuw [2 x i32], ptr %temporary, i64 0, i64 0
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load i64, ptr %index.addr, align 8
  %element1 = getelementptr [2 x i32], ptr %0, i64 0, i64 %1
  %2 = load i32, ptr %element1, align 4
  store i32 %2, ptr %element, align 4
  %element2 = getelementptr inbounds nuw [2 x i32], ptr %temporary, i64 0, i64 1
  %3 = load ptr, ptr %source.addr, align 8
  %4 = load i64, ptr %index.addr, align 8
  %element3 = getelementptr [2 x i32], ptr %3, i64 0, i64 %4
  %5 = load i32, ptr %element3, align 4
  store i32 %5, ptr %element2, align 4
  %6 = load ptr, ptr %source.addr, align 8
  %7 = load ptr, ptr %target.addr, align 8
  %8 = load i64, ptr %index.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @Change(ptr noundef nonnull align 4 dereferenceable(8) %6, ptr noundef nonnull align 4 dereferenceable(8) %7, i64 noundef %8)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call, ptr align 4 %temporary, i64 8, i1 false)
  ret void
}

define noundef nonnull align 4 dereferenceable(8) ptr @Locate(ptr noundef nonnull align 4 dereferenceable(8) %value, ptr noundef nonnull align 8 dereferenceable(8) %index, i64 noundef %replacement) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %index.addr = alloca ptr, align 8
  %replacement.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %index, ptr %index.addr, align 8
  store i64 %replacement, ptr %replacement.addr, align 8
  %0 = load i64, ptr %replacement.addr, align 8
  %1 = load ptr, ptr %index.addr, align 8
  store i64 %0, ptr %1, align 8
  %2 = load ptr, ptr %value.addr, align 8
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef i32 @Read(ptr noundef nonnull align 4 dereferenceable(8) %value, ptr noundef nonnull align 8 dereferenceable(8) %index, i64 noundef %replacement) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %index.addr = alloca ptr, align 8
  %replacement.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %index, ptr %index.addr, align 8
  store i64 %replacement, ptr %replacement.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load ptr, ptr %index.addr, align 8
  %2 = load i64, ptr %replacement.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr @Locate(ptr noundef nonnull align 4 dereferenceable(8) %0, ptr noundef nonnull align 8 dereferenceable(8) %1, i64 noundef %2)
  %3 = load ptr, ptr %index.addr, align 8
  %4 = load i64, ptr %3, align 8
  %element = getelementptr [2 x i32], ptr %call, i64 0, i64 %4
  %5 = load i32, ptr %element, align 4
  store i32 %5, ptr %.result, align 4
  %6 = load i32, ptr %.result, align 4
  ret i32 %6
}

define noundef i32 @Next(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %value.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8
  %4 = load i32, ptr %3, align 4
  store i32 %4, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define noundef i32 @Elements(ptr noundef nonnull align 4 dereferenceable(4) %value, i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %values = alloca [2 x i32], align 4
  store ptr %value, ptr %value.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %element = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 0
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Next(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %element, align 4
  %element1 = getelementptr inbounds nuw [2 x i32], ptr %values, i64 0, i64 1
  %1 = load ptr, ptr %value.addr, align 8
  %call2 = call noundef i32 @Next(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i32 %call2, ptr %element1, align 4
  %2 = load i64, ptr %index.addr, align 8
  %element3 = getelementptr [2 x i32], ptr %values, i64 0, i64 %2
  %3 = load i32, ptr %element3, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define void @Discarded(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %flag.addr = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %value, ptr %value.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @Next(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %value.addr, align 8
  %call1 = call noundef i32 @Next(ptr noundef nonnull align 4 dereferenceable(4) %2)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %3 = load ptr, ptr %value.addr, align 8
  %call2 = call noundef i32 @Next(ptr noundef nonnull align 4 dereferenceable(4) %3)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
