%"struct.Api::Value" = type { i32 }

declare noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator++:func(&mut Api::Value)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4))

declare i32 @"cw:Api::operator++:func(&mut Api::Value,i32)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4), i32 noundef)

declare noundef i32 @"cw:Api::operator--:func(Api::Value)i32"(i64)

declare void @"cw:Api::operator--:func(&move Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4), i32 noundef)

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::Prefix:func(&mut Api::Value)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator++:func(&mut Api::Value)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define i32 @"cw:Api::Postfix:func(&mut Api::Value)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call i32 @"cw:Api::operator++:func(&mut Api::Value,i32)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 0)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:Api::ByValue:func(Api::Value)i32"(i64 %value.coerce) {
entry:
  %.result = alloca i32, align 4
  %value = alloca %"struct.Api::Value", align 4
  %argument = alloca %"struct.Api::Value", align 4
  %coerce1 = alloca i64, align 8
  %coerce = trunc i64 %value.coerce to i32
  store i32 %coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %argument, ptr align 4 %value, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce1, ptr align 4 %argument, i64 4, i1 false)
  %0 = load i64, ptr %coerce1, align 8
  %call = call noundef i32 @"cw:Api::operator--:func(Api::Value)i32"(i64 %0)
  store i32 %call, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define void @"cw:Api::Discard:func(&mut Api::Value)void"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @"cw:Api::operator--:func(&move Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 0)
  ret void
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::Locate:func(&mut Api::Value,&mut i32)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %count) {
entry:
  %.result = alloca ptr, align 8
  %value.addr = alloca ptr, align 8
  %count.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %count.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  store i32 %add, ptr %0, align 4
  %2 = load ptr, ptr %value.addr, align 8
  store ptr %2, ptr %.result, align 8
  %3 = load ptr, ptr %.result, align 8
  ret ptr %3
}

define i32 @"cw:Api::Once:func(&mut Api::Value,&mut i32)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %count) {
entry:
  %.result = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  %count.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load ptr, ptr %count.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::Locate:func(&mut Api::Value,&mut i32)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %call1 = call i32 @"cw:Api::operator++:func(&mut Api::Value,i32)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef 0)
  store i32 %call1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define i32 @"cw:Api::Nested:func(&mut Api::Value)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator++:func(&mut Api::Value)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %call1 = call i32 @"cw:Api::operator++:func(&mut Api::Value,i32)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef 0)
  store i32 %call1, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define i32 @"cw:Explicit:func(&mut Api::Value,i32)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %value, i32 noundef %marker) {
entry:
  %.result = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  %marker.addr = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i32 %marker, ptr %marker.addr, align 4
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i32, ptr %marker.addr, align 4
  %call = call i32 @"cw:Api::operator++:func(&mut Api::Value,i32)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %1)
  store i32 %call, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define i32 @"cw:Indirect:func(&mut Api::Value,i32)Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %value, i32 noundef %marker) {
entry:
  %.result = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  %marker.addr = alloca i32, align 4
  %operation = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store i32 %marker, ptr %marker.addr, align 4
  store ptr @"cw:Api::operator++:func(&mut Api::Value,i32)Api::Value", ptr %operation, align 8
  %0 = load ptr, ptr %operation, align 8
  %1 = load ptr, ptr %value.addr, align 8
  %2 = load i32, ptr %marker.addr, align 4
  %call = call i32 %0(ptr noundef nonnull align 4 dereferenceable(4) %1, i32 noundef %2)
  store i32 %call, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
