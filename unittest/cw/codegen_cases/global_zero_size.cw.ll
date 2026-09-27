%struct.Empty = type { i8 }

@__dso_handle = external hidden global i8
@trace = global i64 0, align 8
@empty = global %struct.Empty zeroinitializer, align 1
@pair = global [2 x %struct.Empty] zeroinitializer, align 1
@none = global [0 x %struct.Empty] zeroinitializer, align 1
@nested = global [2 x [0 x %struct.Empty]] zeroinitializer, align 1
@copied = global [2 x [0 x %struct.Empty]] zeroinitializer, align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @.cw.global_init, ptr null }]

; Function Attrs: nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) #0

define void @Mark(i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i64, ptr @trace, align 8
  %mul = mul i64 %0, 10
  %1 = load i32, ptr %value.addr, align 4
  %conv = sext i32 %1 to i64
  %add = add i64 %mul, %conv
  store i64 %add, ptr @trace, align 8
  ret void
}

define noundef ptr @Empty.ctor(ptr noundef returned %this) {
entry:
  call void @Mark(i32 noundef 1)
  ret ptr %this
}

define noundef ptr @Empty.ctor.1(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  call void @Mark(i32 noundef 2)
  ret ptr %this
}

define noundef ptr @Empty.dtor(ptr noundef returned %this) {
entry:
  call void @Mark(i32 noundef -1)
  ret ptr %this
}

define noundef nonnull align 1 ptr @Source() {
entry:
  %.result = alloca ptr, align 8
  call void @Mark(i32 noundef 3)
  store ptr @nested, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define internal void @.cw.global_var_init() {
entry:
  store i64 0, ptr @trace, align 8
  ret void
}

define internal void @.cw.global_var_init.2() {
entry:
  %call = call noundef ptr @Empty.ctor(ptr noundef returned @empty)
  %0 = call i32 @__cxa_atexit(ptr @Empty.dtor, ptr @empty, ptr @__dso_handle) #0
  ret void
}

define internal void @.cw.global_var_init.3() {
entry:
  %call = call noundef ptr @Empty.ctor(ptr noundef returned @pair)
  %call1 = call noundef ptr @Empty.ctor(ptr noundef returned getelementptr inbounds nuw ([2 x %struct.Empty], ptr @pair, i64 0, i64 1))
  %0 = call i32 @__cxa_atexit(ptr @.cw.global_array_dtor, ptr @pair, ptr @__dso_handle) #0
  ret void
}

define internal void @.cw.global_array_dtor(ptr noundef %object) {
entry:
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %entry
  %array.index = phi i64 [ 2, %entry ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index, 1
  %element = getelementptr inbounds nuw [2 x %struct.Empty], ptr %object, i64 0, i64 %array.previous
  %call = call noundef ptr @Empty.dtor(ptr noundef returned %element)
  %array.finished = icmp eq i64 %array.previous, 0
  br i1 %array.finished, label %array.end, label %array.destroy

array.end:                                        ; preds = %array.destroy
  ret void
}

define internal void @.cw.global_var_init.4() {
entry:
  ret void
}

define internal void @.cw.global_var_init.5() {
entry:
  ret void
}

define internal void @.cw.global_var_init.6() {
entry:
  %call = call noundef nonnull align 1 ptr @Source()
  ret void
}

define internal void @.cw.global_init() {
entry:
  call void @.cw.global_var_init()
  call void @.cw.global_var_init.2()
  call void @.cw.global_var_init.3()
  call void @.cw.global_var_init.4()
  call void @.cw.global_var_init.5()
  call void @.cw.global_var_init.6()
  ret void
}

attributes #0 = { nounwind }
