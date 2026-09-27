%struct.Empty = type { i8 }
%struct.Aligned = type { [0 x i64] }

define void @Make(ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %result = alloca %struct.Empty, align 1
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  ret void
}

define noundef signext i8 @Take(i8 noundef signext %number) {
entry:
  %.result = alloca i8, align 1
  %value = alloca %struct.Empty, align 1
  %number.addr = alloca i8, align 1
  store i8 %number, ptr %number.addr, align 1
  %0 = load i8, ptr %number.addr, align 1
  store i8 %0, ptr %.result, align 1
  %1 = load i8, ptr %.result, align 1
  ret i8 %1
}

define noundef signext i8 @Use(ptr noundef nonnull align 4 dereferenceable(4) %counter, i8 noundef signext %number) {
entry:
  %.result = alloca i8, align 1
  %counter.addr = alloca ptr, align 8
  %number.addr = alloca i8, align 1
  store ptr %counter, ptr %counter.addr, align 8
  store i8 %number, ptr %number.addr, align 1
  %0 = load ptr, ptr %counter.addr, align 8
  call void @Make(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load i8, ptr %number.addr, align 1
  %call = call noundef signext i8 @Take(i8 noundef signext %1)
  store i8 %call, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  ret i8 %2
}

define void @Identity() {
entry:
  %.result = alloca %struct.Aligned, align 8
  %value = alloca %struct.Aligned, align 8
  ret void
}

define void @Form(ptr noundef nonnull align 8 %value) {
entry:
  %value.addr = alloca ptr, align 8
  %result = alloca %struct.Aligned, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @Identity()
  ret void
}

define void @Mixed(ptr sret([3 x i64]) align 8 %.result, i1 noundef zeroext %flag, ptr noundef %value, i8 noundef signext %number) {
entry:
  %empty = alloca %struct.Empty, align 1
  %flag.addr = alloca i8, align 1
  %number.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i8 %number, ptr %number.addr, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

define void @Combine(ptr sret([3 x i64]) align 8 %.result, ptr noundef nonnull align 8 dereferenceable(24) %value, i1 noundef zeroext %flag, i8 noundef signext %number) {
entry:
  %value.addr = alloca ptr, align 8
  %flag.addr = alloca i8, align 1
  %number.addr = alloca i8, align 1
  %argument = alloca [3 x i64], align 8
  store ptr %value, ptr %value.addr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i8 %number, ptr %number.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %1 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %1, i64 24, i1 false)
  %2 = load i8, ptr %number.addr, align 1
  call void @Mixed(ptr sret([3 x i64]) align 8 %.result, i1 noundef zeroext %loadedv, ptr noundef %argument, i8 noundef signext %2)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
