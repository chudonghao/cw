%struct.ZeroDerived = type { %struct.ZeroBase, %struct.Empty }
%struct.ZeroBase = type { [0 x i64] }
%struct.Empty = type { i8 }
%struct.Occupied = type { %struct.ZeroDerived.base, %struct.Empty, i32 }
%struct.ZeroDerived.base = type <{ %struct.ZeroBase, %struct.Empty }>

define i64 @Make(ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca %struct.ZeroDerived, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  call void @llvm.memset.p0.i64(ptr align 8 %.result, i8 0, i64 8, i1 false)
  %3 = load i64, ptr %.result, align 8
  ret i64 %3
}

define i64 @Identity(i64 %value.coerce) {
entry:
  %.result = alloca %struct.ZeroDerived, align 8
  %value = alloca %struct.ZeroDerived, align 8
  store i64 %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 8, i1 false)
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define i64 @Form(ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca %struct.Occupied, align 8
  %counter.addr = alloca ptr, align 8
  %value = alloca %struct.Occupied, align 8
  %temporary = alloca %struct.ZeroDerived, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %call = call i64 @Make(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i64 %call, ptr %temporary, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %value, ptr align 8 %temporary, i64 1, i1 false)
  %empty = getelementptr inbounds nuw %struct.Occupied, ptr %value, i32 0, i32 1
  %number = getelementptr inbounds nuw %struct.Occupied, ptr %value, i32 0, i32 2
  store i32 1, ptr %number, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 8, i1 false)
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef zeroext i1 @Same(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %empty = getelementptr inbounds nuw %struct.Occupied, ptr %0, i32 0, i32 1
  %1 = load ptr, ptr %value.addr, align 8
  %empty1 = getelementptr inbounds nuw %struct.ZeroDerived, ptr %1, i32 0, i32 1
  %cmp = icmp eq ptr %empty, %empty1
  %storedv = zext i1 %cmp to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

define noundef ptr @Base(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
