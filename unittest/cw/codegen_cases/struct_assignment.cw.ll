%struct.Value = type { i32 }

define noundef i32 @CopyAndMove(ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i32, align 4
  %source.addr = alloca ptr, align 8
  %copied = alloca %struct.Value, align 4
  %moved = alloca %struct.Value, align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %copied, ptr align 4 %0, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %copied, i64 4, i1 false)
  %1 = load ptr, ptr %source.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %1, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %moved, ptr align 4 %moved, i64 4, i1 false)
  %number = getelementptr inbounds nuw %struct.Value, ptr %moved, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef nonnull align 4 dereferenceable(4) ptr @Assign(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %middle, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %middle.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %middle, ptr %middle.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %middle.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 4, i1 false)
  %2 = load ptr, ptr %target.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %2, ptr align 4 %1, i64 4, i1 false)
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
