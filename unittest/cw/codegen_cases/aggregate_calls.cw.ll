define void @Make(ptr sret([3 x i64]) align 8 %.result, i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  %element = getelementptr inbounds nuw [3 x i64], ptr %.result, i64 0, i64 0
  %3 = load i8, ptr %value.addr, align 1
  %conv = sext i8 %3 to i64
  store i64 %conv, ptr %element, align 8
  %element1 = getelementptr inbounds nuw [3 x i64], ptr %.result, i64 0, i64 1
  store i64 2, ptr %element1, align 8
  %element2 = getelementptr inbounds nuw [3 x i64], ptr %.result, i64 0, i64 2
  store i64 3, ptr %element2, align 8
  ret void
}

define void @Forward(ptr sret([3 x i64]) align 8 %.result, i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %1 = load ptr, ptr %counter.addr, align 8
  call void @Make(ptr sret([3 x i64]) align 8 %.result, i8 noundef signext %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret void
}

define void @Indirect(ptr sret([3 x i64]) align 8 %.result, ptr noundef %callback, i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load i8, ptr %value.addr, align 1
  %2 = load ptr, ptr %counter.addr, align 8
  call void %0(ptr sret([3 x i64]) align 8 %.result, i8 noundef signext %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  ret void
}

define void @Discard(i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  %call.result = alloca [3 x i64], align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %1 = load ptr, ptr %counter.addr, align 8
  call void @Make(ptr sret([3 x i64]) align 8 %call.result, i8 noundef signext %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret void
}

define noundef i64 @Element(i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter, i64 noundef %index) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %temporary = alloca [3 x i64], align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %1 = load ptr, ptr %counter.addr, align 8
  call void @Make(ptr sret([3 x i64]) align 8 %temporary, i8 noundef signext %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load i64, ptr %index.addr, align 8
  %element = getelementptr [3 x i64], ptr %temporary, i64 0, i64 %2
  %3 = load i64, ptr %element, align 8
  store i64 %3, ptr %.result, align 8
  %4 = load i64, ptr %.result, align 8
  ret i64 %4
}

define noundef nonnull align 8 dereferenceable(24) ptr @Reference(ptr noundef nonnull align 8 dereferenceable(24) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @CopyReference(ptr sret([3 x i64]) align 8 %.result, ptr noundef nonnull align 8 dereferenceable(24) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 8 dereferenceable(24) ptr @Reference(ptr noundef nonnull align 8 dereferenceable(24) %0)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %call, i64 24, i1 false)
  ret void
}

define void @Identity(ptr sret([3 x i64]) align 8 %.result, ptr noundef %value) {
entry:
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

define void @Nested(ptr sret([3 x i64]) align 8 %.result, i8 noundef signext %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %value.addr = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  %argument = alloca [3 x i64], align 8
  store i8 %value, ptr %value.addr, align 1
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load i8, ptr %value.addr, align 1
  %1 = load ptr, ptr %counter.addr, align 8
  call void @Make(ptr sret([3 x i64]) align 8 %argument, i8 noundef signext %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  call void @Identity(ptr sret([3 x i64]) align 8 %.result, ptr noundef %argument)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
