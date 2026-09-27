%struct.Pair = type { i32, i32 }
%struct.Callback = type { ptr }

define noundef nonnull align 4 dereferenceable(4) ptr @Member(ptr noundef nonnull align 4 dereferenceable(8) %value, i32 noundef %input) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %0 = load i32, ptr %input.addr, align 4
  %1 = load ptr, ptr %value.addr, align 8
  %second = getelementptr inbounds nuw %struct.Pair, ptr %1, i32 0, i32 1
  store i32 %0, ptr %second, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %second1 = getelementptr inbounds nuw %struct.Pair, ptr %2, i32 0, i32 1
  store ptr %second1, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef ptr @Pointer(ptr noundef %value, i32 noundef %input) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %0 = load i32, ptr %input.addr, align 4
  %1 = load ptr, ptr %value.addr, align 8
  %first = getelementptr inbounds nuw %struct.Pair, ptr %1, i32 0, i32 0
  store i32 %0, ptr %first, align 4
  %2 = load ptr, ptr %value.addr, align 8
  %first1 = getelementptr inbounds nuw %struct.Pair, ptr %2, i32 0, i32 0
  store ptr %first1, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef i32 @Call(ptr noundef nonnull align 8 dereferenceable(8) %value, i32 noundef %input) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %input.addr = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i32 %input, ptr %input.addr, align 4
  %0 = load ptr, ptr %value.addr, align 8
  %invoke = getelementptr inbounds nuw %struct.Callback, ptr %0, i32 0, i32 0
  %1 = load ptr, ptr %invoke, align 8
  %2 = load i32, ptr %input.addr, align 4
  %call = call noundef i32 %1(i32 noundef %2)
  store i32 %call, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @Temporary() {
entry:
  %.result = alloca i32, align 4
  %temporary = alloca %struct.Pair, align 4
  call void @llvm.memset.p0.i64(ptr align 4 %temporary, i8 0, i64 8, i1 false)
  %first = getelementptr inbounds nuw %struct.Pair, ptr %temporary, i32 0, i32 0
  %0 = load i32, ptr %first, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
