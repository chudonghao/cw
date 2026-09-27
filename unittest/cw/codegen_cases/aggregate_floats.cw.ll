%struct.Homogeneous = type { %struct.Inner, [2 x float] }
%struct.Inner = type { float }
%struct.Mixed = type { float, i32 }
%struct.Padded = type { float, [0 x i64] }
%struct.ZeroArray = type { double, [0 x i64] }
%struct.NestedZeroArray = type { float, [2 x [0 x i32]] }

define %struct.Homogeneous @Nested([3 x float] %value.coerce) {
entry:
  %.result = alloca %struct.Homogeneous, align 4
  %value = alloca %struct.Homogeneous, align 4
  store [3 x float] %value.coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 12, i1 false)
  %0 = load %struct.Homogeneous, ptr %.result, align 4
  ret %struct.Homogeneous %0
}

define noundef [4 x double] @Four([4 x double] noundef %value) {
entry:
  %.result = alloca [4 x double], align 8
  %value.addr = alloca [4 x double], align 8
  store [4 x double] %value, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value.addr, i64 32, i1 false)
  %0 = load [4 x double], ptr %.result, align 8
  ret [4 x double] %0
}

define void @Five(ptr sret([5 x float]) align 4 %.result, ptr noundef %value) {
entry:
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 20, i1 false)
  ret void
}

define i64 @Different(i64 %value.coerce) {
entry:
  %.result = alloca %struct.Mixed, align 4
  %value = alloca %struct.Mixed, align 4
  store i64 %value.coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 8, i1 false)
  %0 = load i64, ptr %.result, align 4
  ret i64 %0
}

define i64 @WithPadding(i64 %value.coerce) {
entry:
  %.result = alloca %struct.Padded, align 8
  %value = alloca %struct.Padded, align 8
  store i64 %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 8, i1 false)
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define i64 @WithZeroArray(i64 %value.coerce) {
entry:
  %.result = alloca %struct.ZeroArray, align 8
  %value = alloca %struct.ZeroArray, align 8
  store i64 %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 8, i1 false)
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define i32 @WithNestedZeroArray(i64 %value.coerce) {
entry:
  %.result = alloca %struct.NestedZeroArray, align 4
  %value = alloca %struct.NestedZeroArray, align 4
  %coerce = trunc i64 %value.coerce to i32
  store i32 %coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 4, i1 false)
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define %struct.Homogeneous @Forward(ptr noundef nonnull align 4 dereferenceable(12) %value) {
entry:
  %.result = alloca %struct.Homogeneous, align 4
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.Homogeneous, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %argument, ptr align 4 %0, i64 12, i1 false)
  %1 = load [3 x float], ptr %argument, align 4
  %call = call %struct.Homogeneous @Nested([3 x float] %1)
  store %struct.Homogeneous %call, ptr %.result, align 4
  %2 = load %struct.Homogeneous, ptr %.result, align 4
  ret %struct.Homogeneous %2
}

define i64 @ForwardZeroArray(ptr noundef nonnull align 8 dereferenceable(8) %value) {
entry:
  %.result = alloca %struct.ZeroArray, align 8
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.ZeroArray, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %0, i64 8, i1 false)
  %1 = load i64, ptr %argument, align 8
  %call = call i64 @WithZeroArray(i64 %1)
  store i64 %call, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
