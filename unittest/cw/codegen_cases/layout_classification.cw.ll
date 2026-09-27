%struct.Floats = type { float, float }
%struct.WithZero = type { float, [0 x float] }
%struct.Pointer = type { ptr }
%struct.Pointers = type { [2 x ptr] }

define %struct.Floats @FloatIdentity([2 x float] %value.coerce) {
entry:
  %.result = alloca %struct.Floats, align 4
  %value = alloca %struct.Floats, align 4
  store [2 x float] %value.coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 8, i1 false)
  %0 = load %struct.Floats, ptr %.result, align 4
  ret %struct.Floats %0
}

define i32 @ZeroIdentity(i64 %value.coerce) {
entry:
  %.result = alloca %struct.WithZero, align 4
  %value = alloca %struct.WithZero, align 4
  %coerce = trunc i64 %value.coerce to i32
  store i32 %coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 4, i1 false)
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define i64 @PointerIdentity(i64 %value.coerce) {
entry:
  %.result = alloca %struct.Pointer, align 8
  %value = alloca %struct.Pointer, align 8
  store i64 %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 8, i1 false)
  %0 = load i64, ptr %.result, align 8
  ret i64 %0
}

define [2 x i64] @PointersIdentity([2 x ptr] %value.coerce) {
entry:
  %.result = alloca %struct.Pointers, align 8
  %value = alloca %struct.Pointers, align 8
  store [2 x ptr] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %0
}

define noundef [2 x i64] @ArrayIdentity([2 x ptr] noundef %value) {
entry:
  %.result = alloca [2 x ptr], align 8
  %value.addr = alloca [2 x ptr], align 8
  store [2 x ptr] %value, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value.addr, i64 16, i1 false)
  %0 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
