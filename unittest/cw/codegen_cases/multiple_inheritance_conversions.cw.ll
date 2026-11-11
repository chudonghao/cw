%struct.Pair = type { %struct.Small, %struct.Wide, i32 }
%struct.Small = type { i32 }
%struct.Wide = type { i64 }
%struct.Twice = type { %struct.First, %struct.Second }
%struct.First = type { %struct.Point }
%struct.Point = type { i32 }
%struct.Second = type { %struct.Point, %struct.Mark }
%struct.Mark = type { i32 }
%struct.Join = type { %struct.Left, %struct.Right }
%struct.Left = type { i32 }
%struct.Right = type { i64 }

define noundef nonnull align 8 dereferenceable(8) ptr @"cw:WideReference:func(&mut Pair)&mut Wide"(ptr noundef nonnull align 8 dereferenceable(20) %pair) {
entry:
  %.result = alloca ptr, align 8
  %pair.addr = alloca ptr, align 8
  store ptr %pair, ptr %pair.addr, align 8
  %0 = load ptr, ptr %pair.addr, align 8
  %base = getelementptr inbounds nuw %struct.Pair, ptr %0, i32 0, i32 1
  store ptr %base, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @"cw:WidePointer:func(*Pair)*Wide"(ptr noundef %pair) {
entry:
  %.result = alloca ptr, align 8
  %pair.addr = alloca ptr, align 8
  store ptr %pair, ptr %pair.addr, align 8
  %0 = load ptr, ptr %pair.addr, align 8
  %base = getelementptr inbounds nuw %struct.Pair, ptr %0, i32 0, i32 1
  %1 = icmp eq ptr %0, null
  %base.null = select i1 %1, ptr null, ptr %base
  store ptr %base.null, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @"cw:SmallPointer:func(*Pair)*Small"(ptr noundef %pair) {
entry:
  %.result = alloca ptr, align 8
  %pair.addr = alloca ptr, align 8
  store ptr %pair, ptr %pair.addr, align 8
  %0 = load ptr, ptr %pair.addr, align 8
  store ptr %0, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef ptr @"cw:MarkPointer:func(*Twice)*Mark"(ptr noundef %twice) {
entry:
  %.result = alloca ptr, align 8
  %twice.addr = alloca ptr, align 8
  store ptr %twice, ptr %twice.addr, align 8
  %0 = load ptr, ptr %twice.addr, align 8
  %base = getelementptr inbounds nuw %struct.Twice, ptr %0, i32 0, i32 1
  %base1 = getelementptr inbounds nuw %struct.Second, ptr %base, i32 0, i32 1
  %1 = icmp eq ptr %0, null
  %base.null = select i1 %1, ptr null, ptr %base1
  store ptr %base.null, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 4 dereferenceable(4) ptr @"cw:SecondPoint:func(&mut Twice)&mut Point"(ptr noundef nonnull align 4 dereferenceable(12) %twice) {
entry:
  %.result = alloca ptr, align 8
  %twice.addr = alloca ptr, align 8
  store ptr %twice, ptr %twice.addr, align 8
  %0 = load ptr, ptr %twice.addr, align 8
  %base = getelementptr inbounds nuw %struct.Twice, ptr %0, i32 0, i32 1
  store ptr %base, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define void @"cw:AssignPoint:func(&mut Twice,&copy Point)void"(ptr noundef nonnull align 4 dereferenceable(12) %twice, ptr noundef nonnull align 4 dereferenceable(4) %source) {
entry:
  %twice.addr = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %twice, ptr %twice.addr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %twice.addr, align 8
  %base = getelementptr inbounds nuw %struct.Twice, ptr %1, i32 0, i32 1
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %base, ptr align 4 %0, i64 4, i1 false)
  ret void
}

declare noundef ptr @"cw:Left:ctor(i32):complete"(ptr noundef returned, i32 noundef)

declare noundef ptr @"cw:Left:ctor(i32):base"(ptr noundef returned, i32 noundef)

declare noundef ptr @"cw:Left:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Left:dtor():base"(ptr noundef returned)

declare noundef ptr @"cw:Right:ctor(i64):complete"(ptr noundef returned, i64 noundef)

declare noundef ptr @"cw:Right:ctor(i64):base"(ptr noundef returned, i64 noundef)

declare noundef ptr @"cw:Right:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:Right:dtor():base"(ptr noundef returned)

define noundef ptr @"cw:Join:ctor():complete"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Left:ctor(i32):base"(ptr noundef returned %this, i32 noundef 1)
  %base = getelementptr inbounds nuw %struct.Join, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @"cw:Right:ctor(i64):base"(ptr noundef returned %base, i64 noundef 2)
  ret ptr %this
}

define noundef ptr @"cw:Join:ctor():base"(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @"cw:Left:ctor(i32):base"(ptr noundef returned %this, i32 noundef 1)
  %base = getelementptr inbounds nuw %struct.Join, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @"cw:Right:ctor(i64):base"(ptr noundef returned %base, i64 noundef 2)
  ret ptr %this
}

define noundef ptr @"cw:Join:dtor():complete"(ptr noundef returned %this) {
entry:
  %base = getelementptr inbounds nuw %struct.Join, ptr %this, i32 0, i32 1
  %call = call noundef ptr @"cw:Right:dtor():base"(ptr noundef returned %base)
  %call1 = call noundef ptr @"cw:Left:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @"cw:Join:dtor():base"(ptr noundef returned %this) {
entry:
  %base = getelementptr inbounds nuw %struct.Join, ptr %this, i32 0, i32 1
  %call = call noundef ptr @"cw:Right:dtor():base"(ptr noundef returned %base)
  %call1 = call noundef ptr @"cw:Left:dtor():base"(ptr noundef returned %this)
  ret ptr %this
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
