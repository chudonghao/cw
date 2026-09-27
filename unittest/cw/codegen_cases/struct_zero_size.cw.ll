%struct.Wrapper = type { %struct.Empty, %struct.Aligned, [2 x %struct.Empty] }
%struct.Empty = type { i8 }
%struct.Aligned = type { [0 x i64] }
%struct.Mixed = type { i8, %struct.Aligned, i8, %struct.Empty }

define void @Zero(i64 noundef %index) {
entry:
  %index.addr = alloca i64, align 8
  %object = alloca %struct.Wrapper, align 8
  %copied = alloca %struct.Wrapper, align 8
  %many = alloca [2 x %struct.Empty], align 1
  %reference = alloca ptr, align 8
  store i64 %index, ptr %index.addr, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %object, i8 0, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %copied, ptr align 8 %object, i64 16, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %copied, ptr align 8 %object, i64 16, i1 false)
  %element = getelementptr inbounds nuw [2 x %struct.Empty], ptr %many, i64 0, i64 0
  %element1 = getelementptr inbounds nuw [2 x %struct.Empty], ptr %many, i64 0, i64 1
  %0 = load i64, ptr %index.addr, align 8
  %element2 = getelementptr [2 x %struct.Empty], ptr %many, i64 0, i64 %0
  store ptr %element2, ptr %reference, align 8
  ret void
}

define void @Store(ptr noundef nonnull align 8 dereferenceable(16) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %tail = getelementptr inbounds nuw %struct.Mixed, ptr %0, i32 0, i32 2
  store i8 1, ptr %tail, align 8
  ret void
}

define noundef nonnull align 8 ptr @Forward(ptr noundef nonnull align 8 %value, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define void @Assign(ptr noundef nonnull align 8 %source, ptr noundef nonnull align 8 %target, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 8 ptr @Forward(ptr noundef nonnull align 8 %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load ptr, ptr %counter.addr, align 8
  %call1 = call noundef nonnull align 8 ptr @Forward(ptr noundef nonnull align 8 %2, ptr noundef nonnull align 4 dereferenceable(4) %3)
  ret void
}

define void @Large(ptr noundef nonnull align 8 %source) {
entry:
  %source.addr = alloca ptr, align 8
  %copied = alloca [18446744073709551615 x %struct.Aligned], align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
