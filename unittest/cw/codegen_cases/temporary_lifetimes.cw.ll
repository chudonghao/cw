%struct.Token = type { i8 }

define noundef ptr @Token.ctor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Token.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef zeroext i1 @Check(ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %.result = alloca i8, align 1
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store i8 0, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define noundef i32 @Next() {
entry:
  %.result = alloca i32, align 4
  store i32 7, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define void @Use(i1 noundef zeroext %test, i32 noundef %next) {
entry:
  %test.addr = alloca i8, align 1
  %next.addr = alloca i32, align 4
  %storedv = zext i1 %test to i8
  store i8 %storedv, ptr %test.addr, align 1
  store i32 %next, ptr %next.addr, align 4
  ret void
}

define void @Short(i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %temporary = alloca %struct.Token, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %land.rhs, label %land.end

land.rhs:                                         ; preds = %entry
  %call = call noundef ptr @Token.ctor(ptr noundef returned %temporary)
  %call1 = call noundef zeroext i1 @Check(ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  br label %land.end

land.end:                                         ; preds = %land.rhs, %entry
  %1 = phi i1 [ false, %entry ], [ %call1, %land.rhs ]
  %call2 = call noundef i32 @Next()
  call void @Use(i1 noundef zeroext %1, i32 noundef %call2)
  br i1 %loadedv, label %cleanup.destroy, label %cleanup.end

cleanup.destroy:                                  ; preds = %land.end
  %call3 = call noundef ptr @Token.dtor(ptr noundef returned %temporary)
  br label %cleanup.end

cleanup.end:                                      ; preds = %cleanup.destroy, %land.end
  ret void
}

define void @Repeat(ptr noundef nonnull align 1 dereferenceable(1) %flag, i1 noundef zeroext %other) {
entry:
  %flag.addr = alloca ptr, align 8
  %other.addr = alloca i8, align 1
  %temporary = alloca %struct.Token, align 1
  %cleanup.active = alloca i1, align 1
  store ptr %flag, ptr %flag.addr, align 8
  %storedv = zext i1 %other to i8
  store i8 %storedv, ptr %other.addr, align 1
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load ptr, ptr %flag.addr, align 8
  %1 = load i8, ptr %0, align 1
  %loadedv = icmp ne i8 %1, 0
  store i1 false, ptr %cleanup.active, align 1
  br i1 %loadedv, label %land.rhs, label %cond.cleanup.false

land.rhs:                                         ; preds = %while.cond
  %2 = load i8, ptr %other.addr, align 1
  %loadedv2 = icmp ne i8 %2, 0
  br i1 %loadedv2, label %land.rhs1, label %cond.cleanup.false

land.rhs1:                                        ; preds = %land.rhs
  %call = call noundef ptr @Token.ctor(ptr noundef returned %temporary)
  store i1 true, ptr %cleanup.active, align 1
  %call3 = call noundef zeroext i1 @Check(ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  br i1 %call3, label %cond.cleanup.true, label %cond.cleanup.false

cond.cleanup.true:                                ; preds = %land.rhs1
  br label %cond.cleanup

cond.cleanup.false:                               ; preds = %land.rhs1, %land.rhs, %while.cond
  br label %cond.cleanup

cond.cleanup:                                     ; preds = %cond.cleanup.false, %cond.cleanup.true
  %condition = phi i1 [ true, %cond.cleanup.true ], [ false, %cond.cleanup.false ]
  %cleanup.active4 = load i1, ptr %cleanup.active, align 1
  br i1 %cleanup.active4, label %cleanup.destroy, label %cleanup.end

cleanup.destroy:                                  ; preds = %cond.cleanup
  %call5 = call noundef ptr @Token.dtor(ptr noundef returned %temporary)
  br label %cleanup.end

cleanup.end:                                      ; preds = %cleanup.destroy, %cond.cleanup
  br i1 %condition, label %while.body, label %while.end

while.body:                                       ; preds = %cleanup.end
  %3 = load ptr, ptr %flag.addr, align 8
  store i8 0, ptr %3, align 1
  br label %while.cond

while.end:                                        ; preds = %cleanup.end
  ret void
}

define noundef i32 @Change(ptr noundef nonnull align 1 dereferenceable(1) %flag) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca ptr, align 8
  store ptr %flag, ptr %flag.addr, align 8
  %0 = load ptr, ptr %flag.addr, align 8
  store i8 0, ptr %0, align 1
  store i32 7, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define void @Choice(i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %temporary = alloca %struct.Token, align 1
  %temporary2 = alloca %struct.Token, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  %cleanup.condition = xor i1 %loadedv, true
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %call = call noundef ptr @Token.ctor(ptr noundef returned %temporary)
  %call1 = call noundef zeroext i1 @Check(ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %call3 = call noundef ptr @Token.ctor(ptr noundef returned %temporary2)
  %call4 = call noundef zeroext i1 @Check(ptr noundef nonnull align 1 dereferenceable(1) %temporary2)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i1 [ %call1, %cond.true ], [ %call4, %cond.false ]
  %call5 = call noundef i32 @Change(ptr noundef nonnull align 1 dereferenceable(1) %flag.addr)
  call void @Use(i1 noundef zeroext %cond, i32 noundef %call5)
  br i1 %cleanup.condition, label %cleanup.destroy, label %cleanup.end

cleanup.destroy:                                  ; preds = %cond.end
  %call6 = call noundef ptr @Token.dtor(ptr noundef returned %temporary2)
  br label %cleanup.end

cleanup.end:                                      ; preds = %cleanup.destroy, %cond.end
  br i1 %loadedv, label %cleanup.destroy7, label %cleanup.end8

cleanup.destroy7:                                 ; preds = %cleanup.end
  %call9 = call noundef ptr @Token.dtor(ptr noundef returned %temporary)
  br label %cleanup.end8

cleanup.end8:                                     ; preds = %cleanup.destroy7, %cleanup.end
  ret void
}
