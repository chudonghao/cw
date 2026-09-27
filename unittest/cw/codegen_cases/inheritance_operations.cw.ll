%struct.Base = type { %struct.Root, i8 }
%struct.Root = type { i32 }
%struct.Derived = type { %struct.Base.base, i8, [2 x i8] }
%struct.Base.base = type <{ %struct.Root, i8 }>

define i64 @Make(i32 noundef %seed) {
entry:
  %.result = alloca %struct.Base, align 4
  %seed.addr = alloca i32, align 4
  %value = alloca %struct.Base, align 4
  store i32 %seed, ptr %seed.addr, align 4
  %number = getelementptr inbounds nuw %struct.Root, ptr %value, i32 0, i32 0
  %0 = load i32, ptr %seed.addr, align 4
  store i32 %0, ptr %number, align 4
  %tag = getelementptr inbounds nuw %struct.Base, ptr %value, i32 0, i32 1
  store i8 9, ptr %tag, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 8, i1 false)
  %1 = load i64, ptr %.result, align 4
  ret i64 %1
}

define i64 @Form(i32 noundef %seed) {
entry:
  %.result = alloca %struct.Derived, align 4
  %seed.addr = alloca i32, align 4
  %value = alloca %struct.Derived, align 4
  %temporary = alloca %struct.Base, align 4
  store i32 %seed, ptr %seed.addr, align 4
  %0 = load i32, ptr %seed.addr, align 4
  %call = call i64 @Make(i32 noundef %0)
  store i64 %call, ptr %temporary, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %value, ptr align 4 %temporary, i64 5, i1 false)
  %own = getelementptr inbounds nuw %struct.Derived, ptr %value, i32 0, i32 1
  store i8 7, ptr %own, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 8, i1 false)
  %1 = load i64, ptr %.result, align 4
  ret i64 %1
}

define noundef zeroext i8 @Assign(ptr noundef nonnull align 4 dereferenceable(6) %target, ptr noundef nonnull align 4 dereferenceable(5) %source) {
entry:
  %.result = alloca i8, align 1
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %base = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %base, align 8
  %1 = load ptr, ptr %source.addr, align 8
  %2 = load ptr, ptr %base, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %2, ptr align 4 %1, i64 5, i1 false)
  %3 = load ptr, ptr %target.addr, align 8
  %own = getelementptr inbounds nuw %struct.Derived, ptr %3, i32 0, i32 1
  %4 = load i8, ptr %own, align 1
  store i8 %4, ptr %.result, align 1
  %5 = load i8, ptr %.result, align 1
  ret i8 %5
}

define [2 x i64] @Copy(ptr noundef nonnull align 4 dereferenceable(16) %source) {
entry:
  %.result = alloca [2 x %struct.Derived], align 4
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %0, i64 16, i1 false)
  %1 = load [2 x i64], ptr %.result, align 4
  ret [2 x i64] %1
}

define i64 @Default() {
entry:
  %.result = alloca %struct.Derived, align 4
  %value = alloca %struct.Derived, align 4
  call void @llvm.memset.p0.i64(ptr align 4 %value, i8 0, i64 5, i1 false)
  %own = getelementptr inbounds nuw %struct.Derived, ptr %value, i32 0, i32 1
  store i8 7, ptr %own, align 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 8, i1 false)
  %0 = load i64, ptr %.result, align 4
  ret i64 %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
