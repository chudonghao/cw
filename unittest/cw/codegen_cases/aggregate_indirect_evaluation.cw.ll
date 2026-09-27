define void @Other(ptr sret([3 x i64]) align 8 %.result, ptr noundef %value, i32 noundef %ignored) {
entry:
  %ignored.addr = alloca i32, align 4
  store i32 %ignored, ptr %ignored.addr, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

define noundef i32 @Replace(ptr noundef nonnull align 8 dereferenceable(8) %callback) {
entry:
  %.result = alloca i32, align 4
  %callback.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  store ptr @Other, ptr %0, align 8
  store i32 0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define void @Invoke(ptr sret([3 x i64]) align 8 %.result, ptr noundef nonnull align 8 dereferenceable(8) %callback, ptr noundef nonnull align 8 dereferenceable(24) %value) {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %argument = alloca [3 x i64], align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %0, align 8
  %2 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %2, i64 24, i1 false)
  %3 = load ptr, ptr %callback.addr, align 8
  %call = call noundef i32 @Replace(ptr noundef nonnull align 8 dereferenceable(8) %3)
  call void %1(ptr sret([3 x i64]) align 8 %.result, ptr noundef %argument, i32 noundef %call)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
