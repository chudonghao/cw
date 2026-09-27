%struct.Product = type { i32 }
%struct.SpecialProduct = type { ptr, %struct.Product }
%struct.SpecialSource = type { %struct.Source, ptr }
%struct.Source = type { ptr }

@.cw.vtable.SpecialProduct = internal constant [3 x ptr] [ptr null, ptr null, ptr @Tag], align 8
@.cw.vtable.Source = internal constant [4 x ptr] [ptr null, ptr null, ptr @__cxa_pure_virtual, ptr @__cxa_pure_virtual], align 8
@.cw.vtable.SpecialSource = internal constant [6 x ptr] [ptr null, ptr null, ptr @.cw.thunk.Pointer, ptr @.cw.thunk.Reference, ptr @Pointer, ptr @Reference], align 8

; Function Attrs: noreturn
declare void @__cxa_pure_virtual() #0

define noundef ptr @Product.ctor(ptr noundef returned %this) {
entry:
  %value = getelementptr inbounds nuw %struct.Product, ptr %this, i32 0, i32 0
  store i32 42, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @Product.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef i32 @Tag(ptr noundef nonnull align 8 dereferenceable(12) %this) {
entry:
  %.result = alloca i32, align 4
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  store i32 7, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef ptr @SpecialProduct.ctor(ptr noundef returned %this) {
entry:
  %base = getelementptr inbounds nuw %struct.SpecialProduct, ptr %this, i32 0, i32 1
  %call = call noundef ptr @Product.ctor(ptr noundef returned %base)
  store ptr getelementptr ([3 x ptr], ptr @.cw.vtable.SpecialProduct, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @SpecialProduct.dtor(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([3 x ptr], ptr @.cw.vtable.SpecialProduct, i32 0, i32 2), ptr %this, align 8
  %base = getelementptr inbounds nuw %struct.SpecialProduct, ptr %this, i32 0, i32 1
  %call = call noundef ptr @Product.dtor(ptr noundef returned %base)
  ret ptr %this
}

define noundef ptr @Pointer(ptr noundef nonnull align 8 dereferenceable(16) %this) {
entry:
  %.result = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %0 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.SpecialSource, ptr %0, i32 0, i32 1
  %1 = load ptr, ptr %target, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 8 dereferenceable(12) ptr @Reference(ptr noundef nonnull align 8 dereferenceable(16) %this) {
entry:
  %.result = alloca ptr, align 8
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %0 = load ptr, ptr %this.addr, align 8
  %target = getelementptr inbounds nuw %struct.SpecialSource, ptr %0, i32 0, i32 1
  %1 = load ptr, ptr %target, align 8
  store ptr %1, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef ptr @Source.ctor(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @.cw.vtable.Source, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @Source.dtor(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([4 x ptr], ptr @.cw.vtable.Source, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @SpecialSource.ctor(ptr noundef returned %this, ptr noundef %target) {
entry:
  %target.addr = alloca ptr, align 8
  store ptr %target, ptr %target.addr, align 8
  %call = call noundef ptr @Source.ctor(ptr noundef returned %this)
  %target1 = getelementptr inbounds nuw %struct.SpecialSource, ptr %this, i32 0, i32 1
  %0 = load ptr, ptr %target.addr, align 8
  store ptr %0, ptr %target1, align 8
  store ptr getelementptr ([6 x ptr], ptr @.cw.vtable.SpecialSource, i32 0, i32 2), ptr %this, align 8
  ret ptr %this
}

define noundef ptr @SpecialSource.dtor(ptr noundef returned %this) {
entry:
  store ptr getelementptr ([6 x ptr], ptr @.cw.vtable.SpecialSource, i32 0, i32 2), ptr %this, align 8
  store ptr getelementptr ([4 x ptr], ptr @.cw.vtable.Source, i32 0, i32 2), ptr %this, align 8
  %call = call noundef ptr @Source.dtor(ptr noundef returned %this)
  ret ptr %this
}

define noundef ptr @GetPointer(ptr noundef nonnull align 8 dereferenceable(8) %source) {
entry:
  %.result = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 0
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef ptr %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef nonnull align 4 dereferenceable(4) ptr @GetReference(ptr noundef nonnull align 8 dereferenceable(8) %source) {
entry:
  %.result = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %vtable = load ptr, ptr %0, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 1
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call = call noundef nonnull align 4 dereferenceable(4) ptr %virtual.callee(ptr noundef nonnull align 8 dereferenceable(8) %0)
  store ptr %call, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define noundef zeroext i1 @Check() {
entry:
  %.result = alloca i8, align 1
  %product = alloca %struct.SpecialProduct, align 8
  %source = alloca %struct.SpecialSource, align 8
  %empty = alloca %struct.SpecialSource, align 8
  %call = call noundef ptr @SpecialProduct.ctor(ptr noundef returned %product)
  %call1 = call noundef ptr @SpecialSource.ctor(ptr noundef returned %source, ptr noundef %product)
  %call2 = call noundef ptr @SpecialSource.ctor(ptr noundef returned %empty, ptr noundef null)
  %call5 = call noundef ptr @GetPointer(ptr noundef nonnull align 8 dereferenceable(8) %source)
  %base = getelementptr inbounds nuw %struct.SpecialProduct, ptr %product, i32 0, i32 1
  %cmp = icmp eq ptr %call5, %base
  br i1 %cmp, label %land.rhs4, label %land.end

land.rhs4:                                        ; preds = %entry
  %call6 = call noundef nonnull align 4 dereferenceable(4) ptr @GetReference(ptr noundef nonnull align 8 dereferenceable(8) %source)
  %base7 = getelementptr inbounds nuw %struct.SpecialProduct, ptr %product, i32 0, i32 1
  %cmp8 = icmp eq ptr %call6, %base7
  br i1 %cmp8, label %land.rhs3, label %land.end

land.rhs3:                                        ; preds = %land.rhs4
  %call9 = call noundef ptr @GetPointer(ptr noundef nonnull align 8 dereferenceable(8) %empty)
  %cmp10 = icmp eq ptr %call9, null
  br i1 %cmp10, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %land.rhs3
  %vtable = load ptr, ptr %source, align 8
  %virtual.slot = getelementptr inbounds ptr, ptr %vtable, i64 2
  %virtual.callee = load ptr, ptr %virtual.slot, align 8
  %call11 = call noundef ptr %virtual.callee(ptr noundef nonnull align 8 dereferenceable(16) %source)
  %cmp12 = icmp eq ptr %call11, %product
  br label %land.end

land.end:                                         ; preds = %land.rhs, %land.rhs3, %land.rhs4, %entry
  %0 = phi i1 [ false, %land.rhs3 ], [ false, %land.rhs4 ], [ false, %entry ], [ %cmp12, %land.rhs ]
  %storedv = zext i1 %0 to i8
  store i8 %storedv, ptr %.result, align 1
  %call13 = call noundef ptr @SpecialSource.dtor(ptr noundef returned %empty)
  %call14 = call noundef ptr @SpecialSource.dtor(ptr noundef returned %source)
  %call15 = call noundef ptr @SpecialProduct.dtor(ptr noundef returned %product)
  %1 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %1, 0
  ret i1 %loadedv
}

define noundef ptr @ConvertPointer(ptr noundef %product) {
entry:
  %.result = alloca ptr, align 8
  %product.addr = alloca ptr, align 8
  store ptr %product, ptr %product.addr, align 8
  %0 = load ptr, ptr %product.addr, align 8
  %base = getelementptr inbounds nuw %struct.SpecialProduct, ptr %0, i32 0, i32 1
  %1 = icmp eq ptr %0, null
  %base.null = select i1 %1, ptr null, ptr %base
  store ptr %base.null, ptr %.result, align 8
  %2 = load ptr, ptr %.result, align 8
  ret ptr %2
}

define noundef nonnull align 4 dereferenceable(4) ptr @ConvertReference(ptr noundef nonnull align 8 dereferenceable(12) %product) {
entry:
  %.result = alloca ptr, align 8
  %product.addr = alloca ptr, align 8
  store ptr %product, ptr %product.addr, align 8
  %0 = load ptr, ptr %product.addr, align 8
  %base = getelementptr inbounds nuw %struct.SpecialProduct, ptr %0, i32 0, i32 1
  store ptr %base, ptr %.result, align 8
  %1 = load ptr, ptr %.result, align 8
  ret ptr %1
}

define internal noundef ptr @.cw.thunk.Pointer(ptr noundef nonnull align 8 dereferenceable(8) %0) {
entry:
  %call = call noundef ptr @Pointer(ptr noundef nonnull align 8 dereferenceable(16) %0)
  %return.adjusted = getelementptr inbounds nuw i8, ptr %call, i64 8
  %1 = icmp eq ptr %call, null
  %return.nullable = select i1 %1, ptr null, ptr %return.adjusted
  ret ptr %return.nullable
}

define internal noundef nonnull align 4 dereferenceable(4) ptr @.cw.thunk.Reference(ptr noundef nonnull align 8 dereferenceable(8) %0) {
entry:
  %call = call noundef nonnull align 8 dereferenceable(12) ptr @Reference(ptr noundef nonnull align 8 dereferenceable(16) %0)
  %return.adjusted = getelementptr inbounds nuw i8, ptr %call, i64 8
  ret ptr %return.adjusted
}

attributes #0 = { noreturn }
