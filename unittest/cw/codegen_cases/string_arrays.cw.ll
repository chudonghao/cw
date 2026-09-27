@.str = private constant [3 x i8] c"abc", align 1
@.str.1 = private constant [3 x i8] c"def", align 1
@.str.2 = private constant [0 x i8] zeroinitializer, align 1

define noundef zeroext i8 @Copy(i64 noundef %index) {
entry:
  %.result = alloca i8, align 1
  %index.addr = alloca i64, align 8
  %text = alloca [3 x i8], align 1
  store i64 %index, ptr %index.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %text, ptr align 1 @.str, i64 3, i1 false)
  %0 = load i64, ptr %index.addr, align 8
  %element = getelementptr [3 x i8], ptr %text, i64 0, i64 %0
  store i8 120, ptr %element, align 1
  %1 = load i64, ptr %index.addr, align 8
  %element1 = getelementptr [3 x i8], ptr %text, i64 0, i64 %1
  %2 = load i8, ptr %element1, align 1
  %3 = load i64, ptr %index.addr, align 8
  %element2 = getelementptr [3 x i8], ptr @.str, i64 0, i64 %3
  %4 = load i8, ptr %element2, align 1
  %add = add i8 %2, %4
  store i8 %add, ptr %.result, align 1
  %5 = load i8, ptr %.result, align 1
  ret i8 %5
}

define noundef nonnull align 1 dereferenceable(3) ptr @Assign(ptr noundef nonnull align 1 dereferenceable(3) %target) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %0, ptr align 1 @.str.1, i64 3, i1 false)
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @Empty() {
entry:
  %text = alloca [0 x i8], align 1
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
