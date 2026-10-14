%struct.Empty = type { i8 }

@__dso_handle = external hidden global i8
@"cw:trace:var" = global i64 0, align 8
@"cw:empty:var" = global %struct.Empty zeroinitializer, align 1
@"cw:pair:var" = global [2 x %struct.Empty] zeroinitializer, align 1
@"cw:none:var" = global [0 x %struct.Empty] zeroinitializer, align 1
@"cw:nested:var" = global [2 x [0 x %struct.Empty]] zeroinitializer, align 1
@"cw:copied:var" = global [2 x [0 x %struct.Empty]] zeroinitializer, align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @"cw:global_init", ptr null }]

; Function Attrs: nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) #0

define void @"cw:Mark:func(i32)void"(i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i64, ptr @"cw:trace:var", align 8
  %mul = mul i64 %0, 10
  %1 = load i32, ptr %value.addr, align 4
  %conv = sext i32 %1 to i64
  %add = add i64 %mul, %conv
  store i64 %add, ptr @"cw:trace:var", align 8
  ret void
}

define noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned %this) {
entry:
  call void @"cw:Mark:func(i32)void"(i32 noundef 1)
  ret ptr %this
}

define noundef ptr @"cw:Empty:ctor():base"(ptr noundef returned %this) {
entry:
  call void @"cw:Mark:func(i32)void"(i32 noundef 1)
  ret ptr %this
}

define noundef ptr @"cw:Empty:ctor(&copy Empty):complete"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  call void @"cw:Mark:func(i32)void"(i32 noundef 2)
  ret ptr %this
}

define noundef ptr @"cw:Empty:ctor(&copy Empty):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  call void @"cw:Mark:func(i32)void"(i32 noundef 2)
  ret ptr %this
}

define noundef ptr @"cw:Empty:dtor():complete"(ptr noundef returned %this) {
entry:
  call void @"cw:Mark:func(i32)void"(i32 noundef -1)
  ret ptr %this
}

define noundef ptr @"cw:Empty:dtor():base"(ptr noundef returned %this) {
entry:
  call void @"cw:Mark:func(i32)void"(i32 noundef -1)
  ret ptr %this
}

define noundef nonnull align 1 ptr @"cw:Source:func()&copy [2][0]Empty"() {
entry:
  %.result = alloca ptr, align 8
  call void @"cw:Mark:func(i32)void"(i32 noundef 3)
  store ptr @"cw:nested:var", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define internal void @"cw:global_var_init"() {
entry:
  store i64 0, ptr @"cw:trace:var", align 8
  ret void
}

define internal void @"cw:global_var_init.1"() {
entry:
  %call = call noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned @"cw:empty:var")
  %0 = call i32 @__cxa_atexit(ptr @"cw:Empty:dtor():complete", ptr @"cw:empty:var", ptr @__dso_handle) #0
  ret void
}

define internal void @"cw:global_var_init.2"() {
entry:
  %call = call noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned @"cw:pair:var")
  %call1 = call noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned getelementptr inbounds nuw ([2 x %struct.Empty], ptr @"cw:pair:var", i64 0, i64 1))
  %0 = call i32 @__cxa_atexit(ptr @"cw:global_array_dtor", ptr @"cw:pair:var", ptr @__dso_handle) #0
  ret void
}

define internal void @"cw:global_array_dtor"(ptr noundef %object) {
entry:
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %entry
  %array.index = phi i64 [ 2, %entry ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index, 1
  %element = getelementptr inbounds nuw [2 x %struct.Empty], ptr %object, i64 0, i64 %array.previous
  %call = call noundef ptr @"cw:Empty:dtor():complete"(ptr noundef returned %element)
  %array.finished = icmp eq i64 %array.previous, 0
  br i1 %array.finished, label %array.end, label %array.destroy

array.end:                                        ; preds = %array.destroy
  ret void
}

define internal void @"cw:global_var_init.3"() {
entry:
  ret void
}

define internal void @"cw:global_var_init.4"() {
entry:
  ret void
}

define internal void @"cw:global_var_init.5"() {
entry:
  %call = call noundef nonnull align 1 ptr @"cw:Source:func()&copy [2][0]Empty"()
  ret void
}

define internal void @"cw:global_init"() {
entry:
  call void @"cw:global_var_init"()
  call void @"cw:global_var_init.1"()
  call void @"cw:global_var_init.2"()
  call void @"cw:global_var_init.3"()
  call void @"cw:global_var_init.4"()
  call void @"cw:global_var_init.5"()
  ret void
}

attributes #0 = { nounwind }
