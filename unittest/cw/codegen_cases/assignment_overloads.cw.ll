%struct.Value = type { i32 }
%struct.Box = type { i32 }

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:operator=:func(&mut Value,i32)&mut Value"(ptr noundef nonnull align 4 dereferenceable(4) %target, i32 noundef %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca i32, align 4
  store ptr %target, ptr %target.addr, align 8
  store i32 %source, ptr %source.addr, align 4
  %0 = load i32, ptr %source.addr, align 4
  %1 = load ptr, ptr %target.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %1, i32 0, i32 0
  store i32 %0, ptr %number, align 4
  %2 = load ptr, ptr %target.addr, align 8
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define noundef i32 @"cw:operator=:func(&copy Value,bool)i32"(ptr noundef nonnull align 4 dereferenceable(4) %target, i1 noundef zeroext %source) {
entry:
  %.result = alloca i32, align 4
  %target.addr = alloca ptr, align 8
  %source.addr = alloca i8, align 1
  store ptr %target, ptr %target.addr, align 8
  %storedv = zext i1 %source to i8
  store i8 %storedv, ptr %source.addr, align 1
  %0 = load i8, ptr %source.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load ptr, ptr %target.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %2, %cond.true ], [ 0, %cond.false ]
  store i32 %cond, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:operator=:func(Value,*i32)i32"(i64 %target.coerce, ptr noundef %source) {
entry:
  %.result = alloca i32, align 4
  %target = alloca %struct.Value, align 4
  %source.addr = alloca ptr, align 8
  %coerce = trunc i64 %target.coerce to i32
  store i32 %coerce, ptr %target, align 4
  store ptr %source, ptr %source.addr, align 8
  %number = getelementptr inbounds nuw %struct.Value, ptr %target, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  %1 = load ptr, ptr %source.addr, align 8
  %2 = load i32, ptr %1, align 4
  %add = add i32 %0, %2
  store i32 %add, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Mutable:func(&mut Value)&mut Value"(ptr noundef nonnull align 4 dereferenceable(4) %target) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:operator=:func(&mut Value,i32)&mut Value"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 7)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @"cw:Readonly:func(&copy Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %target) {
entry:
  %.result = alloca i32, align 4
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %0 = load ptr, ptr %target.addr, align 8
  %call = call noundef i32 @"cw:operator=:func(&copy Value,bool)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0, i1 noundef zeroext true)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:Temporary:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %temporary = alloca %struct.Value, align 4
  call void @llvm.memset.p0.i64(ptr align 4 %temporary, i8 0, i64 4, i1 false)
  %call = call noundef i32 @"cw:operator=:func(&copy Value,bool)i32"(ptr noundef nonnull align 4 dereferenceable(4) %temporary, i1 noundef zeroext true)
  store i32 %call, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:ByValue:func(&copy Value,*i32)i32"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef %source) {
entry:
  %.result = alloca i32, align 4
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %argument = alloca %struct.Value, align 4
  %coerce = alloca i64, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %argument, ptr align 4 %1, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 4 %argument, i64 4, i1 false)
  %2 = load i64, ptr %coerce, align 8
  %call = call noundef i32 @"cw:operator=:func(Value,*i32)i32"(i64 %2, ptr noundef %0)
  store i32 %call, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef nonnull align 4 dereferenceable(8) ptr @"cw:Slice:func(&mut Base,&copy Derived)&mut Base"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(9) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 8, i1 false)
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 4 dereferenceable(9) ptr @"cw:Move:func(&mut Derived,&move Derived)&mut Derived"(ptr noundef nonnull align 4 dereferenceable(9) %target, ptr noundef nonnull align 4 dereferenceable(9) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 9, i1 false)
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef i32 @"cw:operator=:func(&mut Base,&move Derived)i32"(ptr noundef nonnull align 4 dereferenceable(8) %target, ptr noundef nonnull align 4 dereferenceable(9) %source) {
entry:
  %.result = alloca i32, align 4
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  store i32 42, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef nonnull align 4 dereferenceable(9) ptr @"cw:MoveWins:func(&mut Derived,&move Derived)&mut Derived"(ptr noundef nonnull align 4 dereferenceable(9) %target, ptr noundef nonnull align 4 dereferenceable(9) %source) {
entry:
  %.result = alloca ptr, align 8
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %1, ptr align 4 %0, i64 9, i1 false)
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:Box:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Box, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Box:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Box, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Box:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Box:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef i32 @"cw:operator=:func(&mut Box,&mut Box)i32"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i32, align 4
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %value = getelementptr inbounds nuw %struct.Box, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %target.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Box, ptr %2, i32 0, i32 0
  store i32 %1, ptr %value1, align 4
  store i32 1, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef zeroext i1 @"cw:operator=:func(&mut Box,&copy Box)bool"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i8, align 1
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %value = getelementptr inbounds nuw %struct.Box, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value, align 4
  %2 = load ptr, ptr %target.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Box, ptr %2, i32 0, i32 0
  store i32 %1, ptr %value1, align 4
  store i8 1, ptr %.result, align 1
  %3 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %3, 0
  ret i1 %loadedv
}

define noundef i32 @"cw:MutableSource:func(&mut Box,&mut Box)i32"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i32, align 4
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  %call = call noundef i32 @"cw:operator=:func(&mut Box,&mut Box)i32"(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  store i32 %call, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef zeroext i1 @"cw:ConstSource:func(&mut Box,&copy Box)bool"(ptr noundef nonnull align 4 dereferenceable(4) %target, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %.result = alloca i8, align 1
  %target.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %target.addr, align 8
  %call = call noundef zeroext i1 @"cw:operator=:func(&mut Box,&copy Box)bool"(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %storedv = zext i1 %call to i8
  store i8 %storedv, ptr %.result, align 1
  %2 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %2, 0
  ret i1 %loadedv
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
