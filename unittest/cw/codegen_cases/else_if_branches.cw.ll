%struct.Token = type { i8 }

define noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Token:ctor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @"cw:Token:dtor():base"(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef zeroext i1 @"cw:Ready:func(&copy Token)bool"(ptr noundef nonnull align 1 dereferenceable(1) %token) {
entry:
  %.result = alloca i8, align 1
  %token.addr = alloca ptr, align 8
  store ptr %token, ptr %token.addr, align 8
  store i8 1, ptr %.result, align 1
  %0 = load i8, ptr %.result, align 1
  %loadedv = icmp ne i8 %0, 0
  ret i1 %loadedv
}

define void @"cw:StatementChain:func(bool,bool)void"(i1 noundef zeroext %first, i1 noundef zeroext %second) {
entry:
  %first.addr = alloca i8, align 1
  %second.addr = alloca i8, align 1
  %a = alloca %struct.Token, align 1
  %b = alloca %struct.Token, align 1
  %c = alloca %struct.Token, align 1
  %storedv = zext i1 %first to i8
  store i8 %storedv, ptr %first.addr, align 1
  %storedv1 = zext i1 %second to i8
  store i8 %storedv1, ptr %second.addr, align 1
  %0 = load i8, ptr %first.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %a)
  %call2 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %a)
  br label %if.end

if.else:                                          ; preds = %entry
  %1 = load i8, ptr %second.addr, align 1
  %loadedv6 = icmp ne i8 %1, 0
  br i1 %loadedv6, label %if.then3, label %if.else5

if.then3:                                         ; preds = %if.else
  %call7 = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %b)
  %call8 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %b)
  br label %if.end4

if.else5:                                         ; preds = %if.else
  %call9 = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %c)
  %call10 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %c)
  br label %if.end4

if.end4:                                          ; preds = %if.else5, %if.then3
  br label %if.end

if.end:                                           ; preds = %if.end4, %if.then
  ret void
}

define noundef i32 @"cw:ResultChain:func(bool,bool)i32"(i1 noundef zeroext %first, i1 noundef zeroext %second) {
entry:
  %.result = alloca i32, align 4
  %first.addr = alloca i8, align 1
  %second.addr = alloca i8, align 1
  %storedv = zext i1 %first to i8
  store i8 %storedv, ptr %first.addr, align 1
  %storedv1 = zext i1 %second to i8
  store i8 %storedv1, ptr %second.addr, align 1
  %0 = load i8, ptr %first.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  store i32 1, ptr %.result, align 4
  br label %if.end

if.else:                                          ; preds = %entry
  %1 = load i8, ptr %second.addr, align 1
  %loadedv5 = icmp ne i8 %1, 0
  br i1 %loadedv5, label %if.then2, label %if.else4

if.then2:                                         ; preds = %if.else
  store i32 2, ptr %.result, align 4
  br label %if.end3

if.else4:                                         ; preds = %if.else
  store i32 3, ptr %.result, align 4
  br label %if.end3

if.end3:                                          ; preds = %if.else4, %if.then2
  br label %if.end

if.end:                                           ; preds = %if.end3, %if.then
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define void @"cw:ConditionTemporary:func(bool)void"(i1 noundef zeroext %first) {
entry:
  %first.addr = alloca i8, align 1
  %temporary = alloca %struct.Token, align 1
  %storedv = zext i1 %first to i8
  store i8 %storedv, ptr %first.addr, align 1
  %0 = load i8, ptr %first.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  br label %if.end

if.else:                                          ; preds = %entry
  %call = call noundef ptr @"cw:Token:ctor():complete"(ptr noundef returned %temporary)
  %call3 = call noundef zeroext i1 @"cw:Ready:func(&copy Token)bool"(ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  br i1 %call3, label %cond.cleanup.true, label %cond.cleanup.false

cond.cleanup.true:                                ; preds = %if.else
  br label %cond.cleanup

cond.cleanup.false:                               ; preds = %if.else
  br label %cond.cleanup

cond.cleanup:                                     ; preds = %cond.cleanup.false, %cond.cleanup.true
  %condition = phi i1 [ true, %cond.cleanup.true ], [ false, %cond.cleanup.false ]
  %call4 = call noundef ptr @"cw:Token:dtor():complete"(ptr noundef returned %temporary)
  br i1 %condition, label %if.then1, label %if.end2

if.then1:                                         ; preds = %cond.cleanup
  br label %if.end2

if.end2:                                          ; preds = %if.then1, %cond.cleanup
  br label %if.end

if.end:                                           ; preds = %if.end2, %if.then
  ret void
}
