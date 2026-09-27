%struct.Item = type { i32 }

@__dso_handle = external hidden global i8
@trace = global i64 0, align 8
@first = global %struct.Item zeroinitializer, align 4
@second = global %struct.Item zeroinitializer, align 4
@pair = global [2 x %struct.Item] zeroinitializer, align 4
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

define noundef zeroext i1 @Flag() {
entry:
  %.result = alloca i8, align 1
  store i8 1, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef ptr @Item.ctor(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  %1 = load i32, ptr %value.addr, align 4
  call void @Mark(i32 noundef %1)
  ret ptr %this
}

define noundef ptr @Item.dtor(ptr noundef returned %this) {
entry:
  %value = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value, align 4
  %sub = sub i32 0, %0
  call void @Mark(i32 noundef %sub)
  ret ptr %this
}

define void @Observe(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  call void @Mark(i32 noundef %1)
  ret void
}

define internal void @.cw.global_var_init() {
entry:
  store i64 0, ptr @trace, align 8
  ret void
}

define internal void @.cw.global_var_init.1() {
entry:
  %local = alloca %struct.Item, align 4
  %temporary = alloca %struct.Item, align 4
  %call = call noundef ptr @Item.ctor(ptr noundef returned %local, i32 noundef 1)
  %call1 = call noundef zeroext i1 @Flag()
  br i1 %call1, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call2 = call noundef ptr @Item.ctor(ptr noundef returned @first, i32 noundef 2)
  %0 = call i32 @__cxa_atexit(ptr @Item.dtor, ptr @first, ptr @__dso_handle) #0
  br label %if.end

if.else:                                          ; preds = %entry
  %call3 = call noundef ptr @Item.ctor(ptr noundef returned @first, i32 noundef 3)
  %1 = call i32 @__cxa_atexit(ptr @Item.dtor, ptr @first, ptr @__dso_handle) #0
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %call4 = call noundef ptr @Item.ctor(ptr noundef returned %temporary, i32 noundef 4)
  call void @Observe(ptr noundef nonnull align 4 dereferenceable(4) %temporary)
  %call5 = call noundef ptr @Item.dtor(ptr noundef returned %temporary)
  %call6 = call noundef ptr @Item.ctor(ptr noundef returned @second, i32 noundef 5)
  %2 = call i32 @__cxa_atexit(ptr @Item.dtor, ptr @second, ptr @__dso_handle) #0
  %call7 = call noundef ptr @Item.dtor(ptr noundef returned %local)
  ret void
}

define internal void @.cw.global_var_init.2() {
entry:
  %call = call noundef ptr @Item.ctor(ptr noundef returned @pair, i32 noundef 6)
  %call1 = call noundef ptr @Item.ctor(ptr noundef returned getelementptr inbounds nuw ([2 x %struct.Item], ptr @pair, i64 0, i64 1), i32 noundef 7)
  %0 = call i32 @__cxa_atexit(ptr @.cw.global_array_dtor, ptr @pair, ptr @__dso_handle) #0
  ret void
}

define internal void @.cw.global_array_dtor(ptr noundef %object) {
entry:
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %entry
  %array.index = phi i64 [ 2, %entry ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index, 1
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %object, i64 0, i64 %array.previous
  %call = call noundef ptr @Item.dtor(ptr noundef returned %element)
  %array.finished = icmp eq i64 %array.previous, 0
  br i1 %array.finished, label %array.end, label %array.destroy

array.end:                                        ; preds = %array.destroy
  ret void
}

define internal void @.cw.global_init() {
entry:
  call void @.cw.global_var_init()
  call void @.cw.global_var_init.1()
  call void @.cw.global_var_init.2()
  ret void
}

attributes #0 = { nounwind }
