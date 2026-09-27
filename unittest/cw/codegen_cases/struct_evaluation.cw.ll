%struct.Value = type { i32 }

define noundef nonnull align 4 dereferenceable(4) ptr @Change(ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %target) {
entry:
  %.result = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %0, i32 0, i32 0
  store i32 9, ptr %number, align 4
  %1 = load ptr, ptr %target.addr, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define void @Existing(ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %target) {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %source.addr, align 8
  %2 = load ptr, ptr %target.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Change(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %2)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call, ptr align 4 %0, i64 4, i1 false)
  ret void
}

define void @Formed(ptr noundef nonnull align 4 dereferenceable(4) %source, ptr noundef nonnull align 4 dereferenceable(4) %target) {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %temporary = alloca %struct.Value, align 4
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  call void @llvm.memset.p0.i64(ptr align 4 %temporary, i8 0, i64 4, i1 false)
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @Change(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call, ptr align 4 %temporary, i64 4, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
