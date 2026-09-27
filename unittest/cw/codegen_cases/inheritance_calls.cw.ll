%struct.Floats = type { %struct.FloatBase, double }
%struct.FloatBase = type { double }
%struct.BigBase = type { [3 x i64] }
%struct.Big = type { %struct.BigBase, i8 }

define %struct.Floats @FloatIdentity([2 x double] %value.coerce) {
entry:
  %.result = alloca %struct.Floats, align 8
  %value = alloca %struct.Floats, align 8
  store [2 x double] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 16, i1 false)
  %0 = load %struct.Floats, ptr %.result, align 8
  ret %struct.Floats %0
}

define %struct.Floats @FloatCall(ptr noundef nonnull align 8 dereferenceable(16) %value) {
entry:
  %.result = alloca %struct.Floats, align 8
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.Floats, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %0, i64 16, i1 false)
  %1 = load [2 x double], ptr %argument, align 8
  %call = call %struct.Floats @FloatIdentity([2 x double] %1)
  store %struct.Floats %call, ptr %.result, align 8
  %2 = load %struct.Floats, ptr %.result, align 8
  ret %struct.Floats %2
}

define void @MakeBigBase(ptr sret(%struct.BigBase) align 8 %.result) {
entry:
  call void @llvm.memset.p0.i64(ptr align 8 %.result, i8 0, i64 24, i1 false)
  ret void
}

define void @BigCall(ptr sret(%struct.Big) align 8 %.result) {
entry:
  %value = alloca %struct.Big, align 8
  %temporary = alloca %struct.BigBase, align 8
  call void @MakeBigBase(ptr sret(%struct.BigBase) align 8 %temporary)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %value, ptr align 8 %temporary, i64 24, i1 false)
  %flag = getelementptr inbounds nuw %struct.Big, ptr %value, i32 0, i32 1
  store i8 1, ptr %flag, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 32, i1 false)
  ret void
}

define void @Indirect(ptr sret(%struct.Big) align 8 %.result, ptr noundef %callback, ptr noundef nonnull align 8 dereferenceable(25) %value) {
entry:
  %callback.addr = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.Big, align 8
  store ptr %callback, ptr %callback.addr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %callback.addr, align 8
  %1 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %argument, ptr align 8 %1, i64 25, i1 false)
  call void %0(ptr sret(%struct.Big) align 8 %.result, ptr noundef %argument)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
