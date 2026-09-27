%struct.Token = type { i8 }

define noundef ptr @Token.ctor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Token.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @Deferred(i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %outer = alloca %struct.Token, align 1
  %inner = alloca %struct.Token, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = call noundef ptr @Token.ctor(ptr noundef returned %inner)
  %call1 = call noundef ptr @Token.ctor(ptr noundef returned %outer)
  %call2 = call noundef ptr @Token.dtor(ptr noundef returned %inner)
  br label %if.end

if.else:                                          ; preds = %entry
  %call3 = call noundef ptr @Token.ctor(ptr noundef returned %outer)
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %call4 = call noundef ptr @Token.dtor(ptr noundef returned %outer)
  ret void
}

define void @Early(i1 noundef zeroext %flag) {
entry:
  %flag.addr = alloca i8, align 1
  %outer = alloca %struct.Token, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %call = call noundef ptr @Token.ctor(ptr noundef returned %outer)
  %call1 = call noundef ptr @Token.dtor(ptr noundef returned %outer)
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

define void @Loop(i1 noundef zeroext %flag, i1 noundef zeroext %stop) {
entry:
  %flag.addr = alloca i8, align 1
  %stop.addr = alloca i8, align 1
  %outer = alloca %struct.Token, align 1
  %inner = alloca %struct.Token, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %storedv1 = zext i1 %stop to i8
  store i8 %storedv1, ptr %stop.addr, align 1
  %call = call noundef ptr @Token.ctor(ptr noundef returned %outer)
  br label %while.cond

while.cond:                                       ; preds = %if.end, %entry
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %call2 = call noundef ptr @Token.ctor(ptr noundef returned %inner)
  %1 = load i8, ptr %stop.addr, align 1
  %loadedv3 = icmp ne i8 %1, 0
  br i1 %loadedv3, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  %call4 = call noundef ptr @Token.dtor(ptr noundef returned %inner)
  br label %while.end

if.end:                                           ; preds = %while.body
  %call5 = call noundef ptr @Token.dtor(ptr noundef returned %inner)
  br label %while.cond

while.end:                                        ; preds = %if.then, %while.cond
  %call6 = call noundef ptr @Token.dtor(ptr noundef returned %outer)
  ret void
}
