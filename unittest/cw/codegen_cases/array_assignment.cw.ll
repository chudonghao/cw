define noundef i32 @CopyAndMove(ptr noundef nonnull align 4 dereferenceable(8) %source, i64 noundef %index) {
entry:
  %.result = alloca i32, align 4
  %source.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %copied = alloca [2 x i32], align 4
  %moved = alloca [2 x i32], align 4
  store ptr %source, ptr %source.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %copied, ptr align 4 %0, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %copied, i64 8, i1 false)
  %1 = load ptr, ptr %source.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %1, i64 8, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %moved, i64 8, i1 false)
  %2 = load i64, ptr %index.addr, align 8
  %element = getelementptr [2 x i32], ptr %moved, i64 0, i64 %2
  %3 = load i32, ptr %element, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef nonnull align 4 dereferenceable(8) ptr @Assign(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 8, i1 false)
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define void @Chain(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(8) %middle, ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %target.addr = alloca ptr, align 8
  %middle.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %middle, ptr %middle.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %middle.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 8, i1 false)
  %2 = load ptr, ptr %target.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %2, ptr align 4 %1, i64 8, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
