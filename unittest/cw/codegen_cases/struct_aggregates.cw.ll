%struct.Outer = type { i8, %struct.Inner, [2 x %struct.Inner] }
%struct.Inner = type { i16 }

define noundef signext i16 @Nested(i16 noundef signext %value, i64 noundef %index) {
entry:
  %.result = alloca i16, align 2
  %value.addr = alloca i16, align 2
  %index.addr = alloca i64, align 8
  %object = alloca %struct.Outer, align 2
  store i16 %value, ptr %value.addr, align 2
  store i64 %index, ptr %index.addr, align 8
  %leading = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 0
  store i8 1, ptr %leading, align 2
  %inner = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 1
  %value1 = getelementptr inbounds nuw %struct.Inner, ptr %inner, i32 0, i32 0
  %0 = load i16, ptr %value.addr, align 2
  store i16 %0, ptr %value1, align 2
  %items = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 2
  %element = getelementptr inbounds nuw [2 x %struct.Inner], ptr %items, i64 0, i64 0
  call void @llvm.memset.p0.i64(ptr align 2 %element, i8 0, i64 2, i1 false)
  %element2 = getelementptr inbounds nuw [2 x %struct.Inner], ptr %items, i64 0, i64 1
  %inner3 = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 2 %element2, ptr align 2 %inner3, i64 2, i1 false)
  %items4 = getelementptr inbounds nuw %struct.Outer, ptr %object, i32 0, i32 2
  %1 = load i64, ptr %index.addr, align 8
  %element5 = getelementptr [2 x %struct.Inner], ptr %items4, i64 0, i64 %1
  %value6 = getelementptr inbounds nuw %struct.Inner, ptr %element5, i32 0, i32 0
  %2 = load i16, ptr %value6, align 2
  store i16 %2, ptr %.result, align 2
  %3 = load i16, ptr %.result, align 2
  ret i16 %3
}

define noundef signext i16 @Array(ptr noundef nonnull align 2 dereferenceable(16) %source, i64 noundef %index) {
entry:
  %.result = alloca i16, align 2
  %source.addr = alloca ptr, align 8
  %index.addr = alloca i64, align 8
  %copied = alloca [2 x %struct.Outer], align 2
  store ptr %source, ptr %source.addr, align 8
  store i64 %index, ptr %index.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 2 %copied, ptr align 2 %0, i64 16, i1 false)
  %1 = load i64, ptr %index.addr, align 8
  %element = getelementptr [2 x %struct.Outer], ptr %copied, i64 0, i64 %1
  %items = getelementptr inbounds nuw %struct.Outer, ptr %element, i32 0, i32 2
  %2 = load i64, ptr %index.addr, align 8
  %element1 = getelementptr [2 x %struct.Inner], ptr %items, i64 0, i64 %2
  %value = getelementptr inbounds nuw %struct.Inner, ptr %element1, i32 0, i32 0
  %3 = load i16, ptr %value, align 2
  store i16 %3, ptr %.result, align 2
  %4 = load i16, ptr %.result, align 2
  ret i16 %4
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
