%struct.Base = type { i32 }
%struct.Owner = type { %struct.Base, %struct.Part, [2 x %struct.Part] }
%struct.Part = type { i8 }

define noundef ptr @Part.ctor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Part.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Base.ctor(ptr noundef returned %this, i32 noundef %value) {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %value1 = getelementptr inbounds nuw %struct.Base, ptr %this, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value1, align 4
  ret ptr %this
}

define noundef ptr @Base.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Owner.ctor(ptr noundef returned %this) {
entry:
  %call = call noundef ptr @Base.ctor(ptr noundef returned %this, i32 noundef 1)
  %first = getelementptr inbounds nuw %struct.Owner, ptr %this, i32 0, i32 1
  %call1 = call noundef ptr @Part.ctor(ptr noundef returned %first)
  %last = getelementptr inbounds nuw %struct.Owner, ptr %this, i32 0, i32 2
  %element = getelementptr inbounds nuw [2 x %struct.Part], ptr %last, i64 0, i64 0
  %call2 = call noundef ptr @Part.ctor(ptr noundef returned %element)
  %element3 = getelementptr inbounds nuw [2 x %struct.Part], ptr %last, i64 0, i64 1
  %call4 = call noundef ptr @Part.ctor(ptr noundef returned %element3)
  ret ptr %this
}

define noundef ptr @Owner.dtor(ptr noundef returned %this) {
entry:
  %local = alloca %struct.Part, align 1
  %first = getelementptr inbounds nuw %struct.Owner, ptr %this, i32 0, i32 1
  %last = getelementptr inbounds nuw %struct.Owner, ptr %this, i32 0, i32 2
  %call = call noundef ptr @Part.ctor(ptr noundef returned %local)
  %call1 = call noundef ptr @Part.dtor(ptr noundef returned %local)
  br label %array.destroy

array.destroy:                                    ; preds = %array.destroy, %entry
  %array.index = phi i64 [ 2, %entry ], [ %array.previous, %array.destroy ]
  %array.previous = sub i64 %array.index, 1
  %element = getelementptr inbounds nuw [2 x %struct.Part], ptr %last, i64 0, i64 %array.previous
  %call2 = call noundef ptr @Part.dtor(ptr noundef returned %element)
  %array.finished = icmp eq i64 %array.previous, 0
  br i1 %array.finished, label %array.end, label %array.destroy

array.end:                                        ; preds = %array.destroy
  %call3 = call noundef ptr @Part.dtor(ptr noundef returned %first)
  %call4 = call noundef ptr @Base.dtor(ptr noundef returned %this)
  ret ptr %this
}

define void @Destroy() {
entry:
  %owner = alloca %struct.Owner, align 4
  %call = call noundef ptr @Owner.ctor(ptr noundef returned %owner)
  %call1 = call noundef ptr @Owner.dtor(ptr noundef returned %owner)
  ret void
}
