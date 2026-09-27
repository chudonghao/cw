%struct.Number = type { i32 }
%struct.Big = type { [3 x i64] }

define noundef nonnull align 4 dereferenceable(4) ptr @"+"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  store ptr %value1, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @-(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define i32 @"+.1"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %result = alloca %struct.Number, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %value = getelementptr inbounds nuw %struct.Number, ptr %result, i32 0, i32 0
  %0 = load ptr, ptr %left.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  %2 = load ptr, ptr %right.addr, align 8
  %value2 = getelementptr inbounds nuw %struct.Number, ptr %2, i32 0, i32 0
  %3 = load i32, ptr %value2, align 4
  %add = add i32 %1, %3
  store i32 %add, ptr %value, align 4
  %4 = load i32, ptr %result, align 4
  ret i32 %4
}

define void @"+.2"(ptr sret(%struct.Big) align 8 %.result, ptr noundef nonnull align 8 dereferenceable(24) %left, ptr noundef nonnull align 8 dereferenceable(24) %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %0, i64 24, i1 false)
  ret void
}

define void @"!"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Number, ptr %0, i32 0, i32 0
  store i32 0, ptr %value1, align 4
  ret void
}

define void @Assign(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"+"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 7, ptr %call, align 4
  %1 = load ptr, ptr %value.addr, align 8
  call void @"!"(ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret void
}

define noundef nonnull align 4 dereferenceable(4) ptr @Move(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @-(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @Small(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca i32, align 4
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %temporary = alloca %struct.Number, align 4
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %1 = load ptr, ptr %right.addr, align 8
  %call = call i32 @"+.1"(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  store i32 %call, ptr %temporary, align 4
  %value = getelementptr inbounds nuw %struct.Number, ptr %temporary, i32 0, i32 0
  %2 = load i32, ptr %value, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define void @Large(ptr sret(%struct.Big) align 8 %.result, ptr noundef nonnull align 8 dereferenceable(24) %left, ptr noundef nonnull align 8 dereferenceable(24) %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %1 = load ptr, ptr %right.addr, align 8
  call void @"+.2"(ptr sret(%struct.Big) align 8 %.result, ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %1)
  ret void
}

define void @Discard(ptr noundef nonnull align 8 dereferenceable(24) %left, ptr noundef nonnull align 8 dereferenceable(24) %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  %call.result = alloca %struct.Big, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %left.addr, align 8
  %1 = load ptr, ptr %right.addr, align 8
  call void @"+.2"(ptr sret(%struct.Big) align 8 %call.result, ptr noundef nonnull align 8 dereferenceable(24) %0, ptr noundef nonnull align 8 dereferenceable(24) %1)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
