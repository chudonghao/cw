%struct.Item = type { i32 }
%struct.Empty = type { i8 }
%struct.Holder = type { [0 x %struct.Item] }

define noundef ptr @"cw:Item:ctor(i32):complete"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(i32):base"(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(&copy Item):complete"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %other.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(&copy Item):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %other.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(&move Item):complete"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %other.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @"cw:Item:ctor(&move Item):base"(ptr noundef returned %this, ptr noundef nonnull align 4 dereferenceable(4) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  %value = getelementptr inbounds nuw %struct.Item, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %other.addr, align 8
  %value1 = getelementptr inbounds nuw %struct.Item, ptr %0, i32 0, i32 0
  %1 = load i32, ptr %value1, align 4
  store i32 %1, ptr %value, align 4
  ret ptr %this
}

define noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Item:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"cw:Copy:func(&copy [2]Item)void"(ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca [2 x %struct.Item], align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  br label %array.construct

array.construct:                                  ; preds = %array.construct, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.construct ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %value, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Item], ptr %0, i64 0, i64 %array.index
  %call = call noundef ptr @"cw:Item:ctor(&copy Item):complete"(ptr noundef returned %element, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.construct

array.end:                                        ; preds = %array.construct
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %array.end
  %array.index3 = phi i64 [ 2, %array.end ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index3, 1
  %element4 = getelementptr inbounds nuw [2 x %struct.Item], ptr %value, i64 0, i64 %array.previous
  %call5 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %element4)
  %array.finished6 = icmp eq i64 %array.previous, 0
  br i1 %array.finished6, label %array.end2, label %array.destroy

array.end2:                                       ; preds = %array.destroy
  ret void
}

define void @"cw:Move:func(&move [2]Item)void"(ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca [2 x %struct.Item], align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  br label %array.construct

array.construct:                                  ; preds = %array.construct, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.construct ]
  %element = getelementptr inbounds nuw [2 x %struct.Item], ptr %value, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Item], ptr %0, i64 0, i64 %array.index
  %call = call noundef ptr @"cw:Item:ctor(&move Item):complete"(ptr noundef returned %element, ptr noundef nonnull align 4 dereferenceable(4) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.construct

array.end:                                        ; preds = %array.construct
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %array.end
  %array.index3 = phi i64 [ 2, %array.end ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index3, 1
  %element4 = getelementptr inbounds nuw [2 x %struct.Item], ptr %value, i64 0, i64 %array.previous
  %call5 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %element4)
  %array.finished6 = icmp eq i64 %array.previous, 0
  br i1 %array.finished6, label %array.end2, label %array.destroy

array.end2:                                       ; preds = %array.destroy
  ret void
}

define void @"cw:Nested:func(&copy [1][2]Item)void"(ptr noundef nonnull align 4 dereferenceable(8) %source) {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca [1 x [2 x %struct.Item]], align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  br label %array.construct

array.construct:                                  ; preds = %array.end3, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next7, %array.end3 ]
  %element = getelementptr inbounds nuw [1 x [2 x %struct.Item]], ptr %value, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [1 x [2 x %struct.Item]], ptr %0, i64 0, i64 %array.index
  br label %array.construct2

array.construct2:                                 ; preds = %array.construct2, %array.construct
  %array.index4 = phi i64 [ 0, %array.construct ], [ %array.next, %array.construct2 ]
  %element5 = getelementptr inbounds nuw [2 x %struct.Item], ptr %element, i64 0, i64 %array.index4
  %element6 = getelementptr inbounds nuw [2 x %struct.Item], ptr %element1, i64 0, i64 %array.index4
  %call = call noundef ptr @"cw:Item:ctor(&copy Item):complete"(ptr noundef returned %element5, ptr noundef nonnull align 4 dereferenceable(4) %element6)
  %array.next = add i64 %array.index4, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end3, label %array.construct2

array.end3:                                       ; preds = %array.construct2
  %array.next7 = add i64 %array.index, 1
  %array.finished8 = icmp eq i64 %array.next7, 1
  br i1 %array.finished8, label %array.end, label %array.construct

array.end:                                        ; preds = %array.end3
  br label %array.destroy

array.destroy:                                    ; preds = %array.end13, %array.end
  %array.index10 = phi i64 [ 1, %array.end ], [ %array.previous, %array.end13 ]
  %array.previous = sub i64 %array.index10, 1
  %element11 = getelementptr inbounds nuw [1 x [2 x %struct.Item]], ptr %value, i64 0, i64 %array.previous
  br label %array.destroy12

array.destroy12:                                  ; preds = %array.destroy12, %array.destroy
  %array.index14 = phi i64 [ 2, %array.destroy ], [ %array.previous15, %array.destroy12 ]
  %array.previous15 = sub i64 %array.index14, 1
  %element16 = getelementptr inbounds nuw [2 x %struct.Item], ptr %element11, i64 0, i64 %array.previous15
  %call17 = call noundef ptr @"cw:Item:dtor():complete"(ptr noundef returned %element16)
  %array.finished18 = icmp eq i64 %array.previous15, 0
  br i1 %array.finished18, label %array.end13, label %array.destroy12

array.end13:                                      ; preds = %array.destroy12
  %array.finished19 = icmp eq i64 %array.previous, 0
  br i1 %array.finished19, label %array.end9, label %array.destroy

array.end9:                                       ; preds = %array.end13
  ret void
}

define void @"cw:Zero:func(&copy [0]Item)void"(ptr noundef nonnull align 4 %source) {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca [0 x %struct.Item], align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  ret void
}

define noundef nonnull align 4 ptr @"cw:ZeroSource:func(&copy [3][0]Item,&mut i32)&copy [3][0]Item"(ptr noundef nonnull align 4 %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %.result = alloca ptr, align 8
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %counter.addr, align 8
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %counter.addr, align 8
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %source.addr, align 8
  store ptr %3, ptr %.result, align 8
  %4 = load ptr, ptr %.result, align 8
  ret ptr %4
}

define void @"cw:NestedZero:func(&copy [3][0]Item,&mut i32)void"(ptr noundef nonnull align 4 %source, ptr noundef nonnull align 4 dereferenceable(4) %counter) {
entry:
  %source.addr = alloca ptr, align 8
  %counter.addr = alloca ptr, align 8
  %value = alloca [3 x [0 x %struct.Item]], align 4
  store ptr %source, ptr %source.addr, align 8
  store ptr %counter, ptr %counter.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  %1 = load ptr, ptr %counter.addr, align 8
  %call = call noundef nonnull align 4 ptr @"cw:ZeroSource:func(&copy [3][0]Item,&mut i32)&copy [3][0]Item"(ptr noundef nonnull align 4 %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  ret void
}

define noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Empty:ctor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Empty:ctor(&copy Empty):complete"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Empty:ctor(&copy Empty):base"(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %other) {
entry:
  %other.addr = alloca ptr, align 8
  store ptr %other, ptr %other.addr, align 8
  ret ptr %this
}

define noundef ptr @"cw:Empty:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Empty:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @"cw:EmptyElements:func()void"() {
entry:
  %value = alloca [2 x %struct.Empty], align 1
  %element = getelementptr inbounds nuw [2 x %struct.Empty], ptr %value, i64 0, i64 0
  %call = call noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned %element)
  %element1 = getelementptr inbounds nuw [2 x %struct.Empty], ptr %value, i64 0, i64 1
  %call2 = call noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned %element1)
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %entry
  %array.index = phi i64 [ 2, %entry ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index, 1
  %element3 = getelementptr inbounds nuw [2 x %struct.Empty], ptr %value, i64 0, i64 %array.previous
  %call4 = call noundef ptr @"cw:Empty:dtor():complete"(ptr noundef returned %element3)
  %array.finished = icmp eq i64 %array.previous, 0
  br i1 %array.finished, label %array.end, label %array.destroy

array.end:                                        ; preds = %array.destroy
  ret void
}

define void @"cw:CopyEmpty:func(&copy [2]Empty)void"(ptr noundef nonnull align 1 dereferenceable(2) %source) {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca [2 x %struct.Empty], align 1
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  br label %array.construct

array.construct:                                  ; preds = %array.construct, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.construct ]
  %element = getelementptr inbounds nuw [2 x %struct.Empty], ptr %value, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Empty], ptr %0, i64 0, i64 %array.index
  %call = call noundef ptr @"cw:Empty:ctor(&copy Empty):complete"(ptr noundef returned %element, ptr noundef nonnull align 1 dereferenceable(1) %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.construct

array.end:                                        ; preds = %array.construct
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %array.end
  %array.index3 = phi i64 [ 2, %array.end ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index3, 1
  %element4 = getelementptr inbounds nuw [2 x %struct.Empty], ptr %value, i64 0, i64 %array.previous
  %call5 = call noundef ptr @"cw:Empty:dtor():complete"(ptr noundef returned %element4)
  %array.finished6 = icmp eq i64 %array.previous, 0
  br i1 %array.finished6, label %array.end2, label %array.destroy

array.end2:                                       ; preds = %array.destroy
  ret void
}

define void @"cw:EmptyValue:func(Empty)Empty"(ptr sret(%struct.Empty) align 1 %.result, ptr noundef %value) {
entry:
  %call = call noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned %.result)
  ret void
}

define void @"cw:Discard:func()void"() {
entry:
  %temporary = alloca %struct.Empty, align 1
  %argument = alloca %struct.Empty, align 1
  %call = call noundef ptr @"cw:Empty:ctor():complete"(ptr noundef returned %argument)
  call void @"cw:EmptyValue:func(Empty)Empty"(ptr sret(%struct.Empty) align 1 %temporary, ptr noundef %argument)
  %call1 = call noundef ptr @"cw:Empty:dtor():complete"(ptr noundef returned %temporary)
  %call2 = call noundef ptr @"cw:Empty:dtor():complete"(ptr noundef returned %argument)
  ret void
}

define noundef ptr @"cw:Holder:ctor(&copy Holder):complete"(ptr noundef returned %this, ptr noundef nonnull align 4 %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %items = getelementptr inbounds nuw %struct.Holder, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %source.addr, align 8
  %items1 = getelementptr inbounds nuw %struct.Holder, ptr %0, i32 0, i32 0
  ret ptr %this
}

define noundef ptr @"cw:Holder:ctor(&copy Holder):base"(ptr noundef returned %this, ptr noundef nonnull align 4 %source) {
entry:
  %source.addr = alloca ptr, align 8
  store ptr %source, ptr %source.addr, align 8
  %items = getelementptr inbounds nuw %struct.Holder, ptr %this, i32 0, i32 0
  %0 = load ptr, ptr %source.addr, align 8
  %items1 = getelementptr inbounds nuw %struct.Holder, ptr %0, i32 0, i32 0
  ret ptr %this
}

define noundef ptr @"cw:Holder:dtor():complete"(ptr noundef returned %this) {
entry:
  %items = getelementptr inbounds nuw %struct.Holder, ptr %this, i32 0, i32 0
  ret ptr %this
}

define noundef ptr @"cw:Holder:dtor():base"(ptr noundef returned %this) {
entry:
  %items = getelementptr inbounds nuw %struct.Holder, ptr %this, i32 0, i32 0
  ret ptr %this
}

define void @"cw:Holders:func(&copy [2]Holder)void"(ptr noundef nonnull align 4 %source) {
entry:
  %source.addr = alloca ptr, align 8
  %value = alloca [2 x %struct.Holder], align 4
  store ptr %source, ptr %source.addr, align 8
  %0 = load ptr, ptr %source.addr, align 8
  br label %array.construct

array.construct:                                  ; preds = %array.construct, %entry
  %array.index = phi i64 [ 0, %entry ], [ %array.next, %array.construct ]
  %element = getelementptr inbounds nuw [2 x %struct.Holder], ptr %value, i64 0, i64 %array.index
  %element1 = getelementptr inbounds nuw [2 x %struct.Holder], ptr %0, i64 0, i64 %array.index
  %call = call noundef ptr @"cw:Holder:ctor(&copy Holder):complete"(ptr noundef returned %element, ptr noundef nonnull align 4 %element1)
  %array.next = add i64 %array.index, 1
  %array.finished = icmp eq i64 %array.next, 2
  br i1 %array.finished, label %array.end, label %array.construct

array.end:                                        ; preds = %array.construct
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %array.end
  %array.index3 = phi i64 [ 2, %array.end ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index3, 1
  %element4 = getelementptr inbounds nuw [2 x %struct.Holder], ptr %value, i64 0, i64 %array.previous
  %call5 = call noundef ptr @"cw:Holder:dtor():complete"(ptr noundef returned %element4)
  %array.finished6 = icmp eq i64 %array.previous, 0
  br i1 %array.finished6, label %array.end2, label %array.destroy

array.end2:                                       ; preds = %array.destroy
  ret void
}
