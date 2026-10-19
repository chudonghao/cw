%struct.Result = type { i32 }
%"struct.Api::Value" = type { i32 }

@"cw:destroyed:var" = global i32 0, align 4
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @"cw:global_init", ptr null }]

define noundef ptr @"cw:Result:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Result, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Result:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Result, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Result:dtor():complete"(ptr noundef returned %this) {
entry:
  %0 = load i32, ptr @"cw:destroyed:var", align 4
  %add = add i32 %0, 1
  store i32 %add, ptr @"cw:destroyed:var", align 4
  ret ptr %this
}

define noundef ptr @"cw:Result:dtor():base"(ptr noundef returned %this) {
entry:
  %0 = load i32, ptr @"cw:destroyed:var", align 4
  %add = add i32 %0, 1
  store i32 %add, ptr @"cw:destroyed:var", align 4
  ret ptr %this
}

define noundef i32 @"cw:Api::operator+=:func(Api::Value,i32)i32"(i64 %left.coerce, i32 noundef %right) {
entry:
  %.result = alloca i32, align 4
  %left = alloca %"struct.Api::Value", align 4
  %right.addr = alloca i32, align 4
  %coerce = trunc i64 %left.coerce to i32
  store i32 %coerce, ptr %left, align 4
  store i32 %right, ptr %right.addr, align 4
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %left, i32 0, i32 0
  %0 = load i32, ptr %number, align 4
  %1 = load i32, ptr %right.addr, align 4
  %add = add i32 %0, %1
  store i32 %add, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator-=:func(&mut Api::Value,&mut Api::Value)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %.result = alloca ptr, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %right.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @"cw:Api::operator*=:func(&mut Api::Value,i32)Result"(ptr sret(%struct.Result) align 4 %.result, ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %call = call noundef ptr @"cw:Result:ctor(i32):complete"(ptr noundef returned %.result, i32 noundef %0)
  ret void
}

define void @"cw:Api::operator/=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %3 = icmp eq i32 %0, -1
  br i1 %3, label %div.negone, label %div.normal

div.negone:                                       ; preds = %entry
  %sub = sub i32 0, %2
  br label %div.end

div.normal:                                       ; preds = %entry
  %div = sdiv i32 %2, %0
  br label %div.end

div.end:                                          ; preds = %div.normal, %div.negone
  %div1 = phi i32 [ %sub, %div.negone ], [ %div, %div.normal ]
  store i32 %div1, ptr %number, align 4
  ret void
}

define void @"cw:Api::operator%=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %3 = icmp eq i32 %0, -1
  br i1 %3, label %rem.negone, label %rem.normal

rem.negone:                                       ; preds = %entry
  br label %rem.end

rem.normal:                                       ; preds = %entry
  %rem = srem i32 %2, %0
  br label %rem.end

rem.end:                                          ; preds = %rem.normal, %rem.negone
  %rem1 = phi i32 [ 0, %rem.negone ], [ %rem, %rem.normal ]
  store i32 %rem1, ptr %number, align 4
  ret void
}

define void @"cw:Api::operator&=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %and = and i32 %2, %0
  store i32 %and, ptr %number, align 4
  ret void
}

define void @"cw:Api::operator|=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %or = or i32 %2, %0
  store i32 %or, ptr %number, align 4
  ret void
}

define void @"cw:Api::operator^=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load i32, ptr %right.addr, align 4
  %1 = load ptr, ptr %left.addr, align 8
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %1, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %xor = xor i32 %2, %0
  store i32 %xor, ptr %number, align 4
  ret void
}

define noundef i64 @"cw:Api::operator<<=:func(&mut Api::Value,i64)i64"(ptr noundef nonnull align 4 dereferenceable(4) %left, i64 noundef %right) {
entry:
  %.result = alloca i64, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i64, align 8
  store ptr %left, ptr %left.addr, align 8
  store i64 %right, ptr %right.addr, align 8
  %0 = load i64, ptr %right.addr, align 8
  store i64 %0, ptr %.result, align 8
  %1 = load i64, ptr %.result, align 8
  ret i64 %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator>>=:func(&mut Api::Value,i32)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %left, i32 noundef %right) {
entry:
  %.result = alloca ptr, align 8
  %left.addr = alloca ptr, align 8
  %right.addr = alloca i32, align 4
  store ptr %left, ptr %left.addr, align 8
  store i32 %right, ptr %right.addr, align 4
  %0 = load ptr, ptr %left.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef i32 @"cw:Api::Change:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %0, i32 0, i32 0
  store i32 9, ptr %number, align 4
  store i32 1, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @"cw:Api::Syntax:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %argument = alloca %"struct.Api::Value", align 4
  %coerce = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Api::Change:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %1 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %argument, ptr align 4 %1, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 4 %argument, i64 4, i1 false)
  %2 = load i64, ptr %coerce, align 8
  %call1 = call noundef i32 @"cw:Api::operator+=:func(Api::Value,i32)i32"(i64 %2, i32 noundef %call)
  store i32 %call1, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:Api::Explicit:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %argument = alloca %"struct.Api::Value", align 4
  %coerce = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %argument, ptr align 4 %0, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 4 %argument, i64 4, i1 false)
  %1 = load i64, ptr %coerce, align 8
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Api::Change:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %call1 = call noundef i32 @"cw:Api::operator+=:func(Api::Value,i32)i32"(i64 %1, i32 noundef %call)
  store i32 %call1, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define void @"cw:Api::ReferenceResult:func(&mut Api::Value,&mut Api::Value)void"(ptr noundef nonnull align 4 dereferenceable(4) %left, ptr noundef nonnull align 4 dereferenceable(4) %right) {
entry:
  %left.addr = alloca ptr, align 8
  %right.addr = alloca ptr, align 8
  store ptr %left, ptr %left.addr, align 8
  store ptr %right, ptr %right.addr, align 8
  %0 = load ptr, ptr %right.addr, align 8
  %1 = load ptr, ptr %left.addr, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator-=:func(&mut Api::Value,&mut Api::Value)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %1, ptr noundef nonnull align 4 dereferenceable(4) %0)
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %call, i32 0, i32 0
  %2 = load i32, ptr %number, align 4
  %add = add i32 %2, 3
  store i32 %add, ptr %number, align 4
  ret void
}

define void @"cw:Api::Calls:func(&mut Api::Value)void"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %value.addr = alloca ptr, align 8
  %temporary = alloca %struct.Result, align 4
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @"cw:Api::operator/=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 1)
  %1 = load ptr, ptr %value.addr, align 8
  call void @"cw:Api::operator%=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %1, i32 noundef 3)
  %2 = load ptr, ptr %value.addr, align 8
  call void @"cw:Api::operator&=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %2, i32 noundef 7)
  %3 = load ptr, ptr %value.addr, align 8
  call void @"cw:Api::operator|=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %3, i32 noundef 1)
  %4 = load ptr, ptr %value.addr, align 8
  call void @"cw:Api::operator^=:func(&mut Api::Value,i32)void"(ptr noundef nonnull align 4 dereferenceable(4) %4, i32 noundef 2)
  %5 = load ptr, ptr %value.addr, align 8
  call void @"cw:Api::operator*=:func(&mut Api::Value,i32)Result"(ptr sret(%struct.Result) align 4 %temporary, ptr noundef nonnull align 4 dereferenceable(4) %5, i32 noundef 5)
  %call = call noundef ptr @"cw:Result:dtor():complete"(ptr noundef returned %temporary)
  %6 = load ptr, ptr %value.addr, align 8
  %call1 = call noundef nonnull align 4 dereferenceable(4) ptr @"cw:Api::operator>>=:func(&mut Api::Value,i32)&mut Api::Value"(ptr noundef nonnull align 4 dereferenceable(4) %6, i32 noundef -1)
  %number = getelementptr inbounds nuw %"struct.Api::Value", ptr %call1, i32 0, i32 0
  %7 = load i32, ptr %number, align 4
  %add = add i32 %7, 1
  store i32 %add, ptr %number, align 4
  ret void
}

define noundef i32 @"cw:Qualified:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %argument = alloca %"struct.Api::Value", align 4
  %coerce = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %argument, ptr align 4 %0, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 4 %argument, i64 4, i1 false)
  %1 = load i64, ptr %coerce, align 8
  %2 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Api::Change:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %2)
  %call1 = call noundef i32 @"cw:Api::operator+=:func(Api::Value,i32)i32"(i64 %1, i32 noundef %call)
  store i32 %call1, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @"cw:Indirect:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  %operation = alloca ptr, align 8
  %argument = alloca %"struct.Api::Value", align 4
  %coerce = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr @"cw:Api::operator+=:func(Api::Value,i32)i32", ptr %operation, align 8
  %0 = load ptr, ptr %operation, align 8
  %1 = load ptr, ptr %value.addr, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %argument, ptr align 4 %1, i64 4, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %coerce, ptr align 4 %argument, i64 4, i1 false)
  %2 = load i64, ptr %coerce, align 8
  %3 = load ptr, ptr %value.addr, align 8
  %call = call noundef i32 @"cw:Api::Change:func(&mut Api::Value)i32"(ptr noundef nonnull align 4 dereferenceable(4) %3)
  %call1 = call noundef i32 %0(i64 %2, i32 noundef %call)
  store i32 %call1, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}

define noundef i64 @"cw:UnmaskedCount:func(&mut Api::Value,i64)i64"(ptr noundef nonnull align 4 dereferenceable(4) %value, i64 noundef %count) {
entry:
  %.result = alloca i64, align 8
  %value.addr = alloca ptr, align 8
  %count.addr = alloca i64, align 8
  store ptr %value, ptr %value.addr, align 8
  store i64 %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %1 = load i64, ptr %count.addr, align 8
  %call = call noundef i64 @"cw:Api::operator<<=:func(&mut Api::Value,i64)i64"(ptr noundef nonnull align 4 dereferenceable(4) %0, i64 noundef %1)
  store i64 %call, ptr %.result, align 8
  %2 = load i64, ptr %.result, align 8
  ret i64 %2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

define internal void @"cw:global_var_init"() {
entry:
  store i32 0, ptr @"cw:destroyed:var", align 4
  ret void
}

define internal void @"cw:global_init"() {
entry:
  call void @"cw:global_var_init"()
  ret void
}

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
