%struct.Pair = type { i64, i64 }
%struct.Triple = type { i64, i64, i64 }

define noundef i32 @ChangeSmall(ptr noundef nonnull align 8 dereferenceable(16) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %first = getelementptr inbounds nuw %struct.Pair, ptr %0, i32 0, i32 0
  store i64 99, ptr %first, align 8
  store i32 0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i64 @TakeSmall([2 x i64] %value.coerce, i32 noundef %ignored) {
entry:
  %.result = alloca i64, align 8
  %value = alloca %struct.Pair, align 8
  %ignored.addr = alloca i32, align 4
  store [2 x i64] %value.coerce, ptr %value, align 8
  store i32 %ignored, ptr %ignored.addr, align 4
  %second = getelementptr inbounds nuw %struct.Pair, ptr %value, i32 0, i32 1
  store i64 7, ptr %second, align 8
  %first = getelementptr inbounds nuw %struct.Pair, ptr %value, i32 0, i32 0
  %0 = load i64, ptr %first, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @Small(ptr noundef nonnull align 8 dereferenceable(16) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.Pair, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %0, i64 16, i1 false)
  %1 = load [2 x i64], ptr %argument, align 8
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @ChangeSmall(ptr noundef nonnull align 8 dereferenceable(16) %2)
  %call1 = call noundef i64 @TakeSmall([2 x i64] %1, i32 noundef %call)
  store i64 %call1, ptr %.result, align 8
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define noundef i32 @ChangeLarge(ptr noundef nonnull align 8 dereferenceable(24) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %first = getelementptr inbounds nuw %struct.Triple, ptr %0, i32 0, i32 0
  store i64 99, ptr %first, align 8
  store i32 0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i64 @TakeLarge(ptr noundef %value, i32 noundef %ignored) {
entry:
  %.result = alloca i64, align 8
  %ignored.addr = alloca i32, align 4
  store i32 %ignored, ptr %ignored.addr, align 4
  %second = getelementptr inbounds nuw %struct.Triple, ptr %value, i32 0, i32 1
  store i64 7, ptr %second, align 8
  %first = getelementptr inbounds nuw %struct.Triple, ptr %value, i32 0, i32 0
  %0 = load i64, ptr %first, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef i64 @Large(ptr noundef nonnull align 8 dereferenceable(24) %value) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.Triple, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %0, i64 24, i1 false)
  %1 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @ChangeLarge(ptr noundef nonnull align 8 dereferenceable(24) %1)
  %call1 = call noundef i64 @TakeLarge(ptr noundef %argument, i32 noundef %call)
  store i64 %call1, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
