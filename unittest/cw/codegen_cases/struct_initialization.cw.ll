%struct.Padded = type { i8, i32, i8 }
%struct.Defaults = type { i16, i8, float, double, ptr, ptr, [2 x i32] }

define noundef zeroext i1 @Fields(i32 noundef %number, i1 noundef zeroext %enabled) {
entry:
  %.result = alloca i8, align 1
  %number.addr = alloca i32, align 4
  %enabled.addr = alloca i8, align 1
  %value = alloca %struct.Padded, align 4
  store i32 %number, ptr %number.addr, align 4
  %storedv = zext i1 %enabled to i8
  store i8 %storedv, ptr %enabled.addr, align 1
  %tag = getelementptr inbounds nuw %struct.Padded, ptr %value, i32 0, i32 0
  store i8 1, ptr %tag, align 4
  %number1 = getelementptr inbounds nuw %struct.Padded, ptr %value, i32 0, i32 1
  %0 = load i32, ptr %number.addr, align 4
  store i32 %0, ptr %number1, align 4
  %enabled2 = getelementptr inbounds nuw %struct.Padded, ptr %value, i32 0, i32 2
  %1 = load i8, ptr %enabled.addr, align 1
  %loadedv = icmp ne i8 %1, 0
  %storedv3 = zext i1 %loadedv to i8
  store i8 %storedv3, ptr %enabled2, align 4
  %enabled4 = getelementptr inbounds nuw %struct.Padded, ptr %value, i32 0, i32 2
  %2 = load i8, ptr %enabled4, align 4
  %loadedv5 = icmp ne i8 %2, 0
  %storedv6 = zext i1 %loadedv5 to i8
  store i8 %storedv6, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  %loadedv7 = icmp ne i8 %3, 0
  ret i1 %loadedv7
}

define noundef ptr @Default() {
entry:
  %.result = alloca ptr, align 8
  %value = alloca %struct.Defaults, align 8
  call void @llvm.memset.p0.i64(ptr align 8 %value, i8 0, i64 40, i1 false)
  %pointer = getelementptr inbounds nuw %struct.Defaults, ptr %value, i32 0, i32 4
  %0 = load ptr, ptr %pointer, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
