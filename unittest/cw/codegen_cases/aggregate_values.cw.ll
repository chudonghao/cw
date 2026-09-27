%struct.Byte = type { i8 }
%struct.Odd = type { [3 x i8] }
%struct.Pair = type { i64, i64 }
%struct.Pointers = type { ptr, ptr }
%struct.Block = type { [3 x i64] }

define i8 @Small(i64 %value.coerce) {
entry:
  %.result = alloca %struct.Byte, align 1
  %value = alloca %struct.Byte, align 1
  %coerce = trunc i64 %value.coerce to i8
  store i8 %coerce, ptr %value, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %.result, ptr align 1 %value, i64 1, i1 false)
  %0 = load i8, ptr %.result, align 1
  ret i8 %0
}

define i24 @Three(i64 %value.coerce) {
entry:
  %.result = alloca %struct.Odd, align 1
  %value = alloca %struct.Odd, align 1
  %coerce = trunc i64 %value.coerce to i24
  store i24 %coerce, ptr %value, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %.result, ptr align 1 %value, i64 3, i1 false)
  %0 = load i24, ptr %.result, align 1
  ret i24 %0
}

define [2 x i64] @TwoWords([2 x i64] %value.coerce) {
entry:
  %.result = alloca %struct.Pair, align 8
  %value = alloca %struct.Pair, align 8
  store [2 x i64] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %0
}

define [2 x i64] @Addresses([2 x ptr] %value.coerce) {
entry:
  %.result = alloca %struct.Pointers, align 8
  %value = alloca %struct.Pointers, align 8
  store [2 x ptr] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %0
}

define void @Structure(ptr sret(%struct.Block) align 8 %.result, ptr noundef %value) {
entry:
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

define i24 @CopyThree(ptr noundef nonnull align 1 dereferenceable(3) %value) {
entry:
  %.result = alloca %struct.Odd, align 1
  %value.addr = alloca ptr, align 8
  %argument = alloca %struct.Odd, align 1
  %coerce = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %argument, ptr align 1 %0, i64 3, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 1 %argument, i64 3, i1 false)
  %1 = load i64, ptr %coerce, align 8
  %call = call i24 @Three(i64 %1)
  store i24 %call, ptr %.result, align 1
  %2 = load i24, ptr %.result, align 1
  ret i24 %2
}

define [2 x i64] @Nine([2 x i64] %value.coerce) {
entry:
  %.result = alloca [9 x i8], align 1
  %value = alloca [9 x i8], align 1
  %coerce = alloca [2 x i64], align 8
  %coerce1 = alloca [2 x i64], align 8
  store [2 x i64] %value.coerce, ptr %coerce, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %value, ptr align 8 %coerce, i64 9, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %.result, ptr align 1 %value, i64 9, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce1, ptr align 1 %.result, i64 9, i1 false)
  %0 = load [2 x i64], ptr %coerce1, align 8
  ret [2 x i64] %0
}

define void @Large(ptr sret([3 x i64]) align 8 %.result, ptr noundef %value) {
entry:
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 24, i1 false)
  ret void
}

define noundef i16 @Boolean(i64 %value.coerce) {
entry:
  %.result = alloca [2 x i8], align 1
  %value = alloca [2 x i8], align 1
  %coerce = trunc i64 %value.coerce to i16
  store i16 %coerce, ptr %value, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %.result, ptr align 1 %value, i64 2, i1 false)
  %0 = load i16, ptr %.result, align 1
  ret i16 %0
}

define [2 x i64] @CopyNine(ptr noundef nonnull align 1 dereferenceable(9) %value) {
entry:
  %.result = alloca [9 x i8], align 1
  %value.addr = alloca ptr, align 8
  %argument = alloca [9 x i8], align 1
  %coerce = alloca [2 x i64], align 8
  %coerce1 = alloca [2 x i64], align 8
  %coerce2 = alloca [2 x i64], align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %argument, ptr align 1 %0, i64 9, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 1 %argument, i64 9, i1 false)
  %1 = load [2 x i64], ptr %coerce, align 8
  %call = call [2 x i64] @Nine([2 x i64] %1)
  store [2 x i64] %call, ptr %coerce1, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %.result, ptr align 8 %coerce1, i64 9, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce2, ptr align 1 %.result, i64 9, i1 false)
  %2 = load [2 x i64], ptr %coerce2, align 8
  ret [2 x i64] %2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
