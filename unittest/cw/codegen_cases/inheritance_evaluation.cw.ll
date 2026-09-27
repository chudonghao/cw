%struct.Derived = type { %struct.Base, i32 }
%struct.Base = type { i32 }

define void @Assign(ptr noundef %source, ptr noundef %target, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %source.addr = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(8) ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  %2 = load ptr, ptr %target.addr, align 8
  %3 = load ptr, ptr %counter.addr, align 8
  %call1 = call noundef nonnull align 4 dereferenceable(8) ptr %2(ptr noundef nonnull align 4 dereferenceable(4) %3)
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %call1, ptr align 4 %call, i64 4, i1 false)
  ret void
}

define noundef ptr @Convert(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %callback.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef ptr %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store ptr %call, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @Temporary(ptr noundef %callback, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca i32, align 4
  %callback.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %temporary = alloca %struct.Derived, align 4
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call i64 %0(ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i64 %call, ptr %temporary, align 4
  %number = getelementptr inbounds nuw %struct.Base, ptr %temporary, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
