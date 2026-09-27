define noundef i32 @Replace(ptr noundef nonnull align 4 dereferenceable(4) %value) {
entry:
  %.result = alloca i32, align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  store i32 71, ptr %0, align 4
  %1 = load ptr, ptr %value.addr, align 8
  %2 = load i32, ptr %1, align 4
  store i32 %2, ptr %.result, align 4
  %3 = load i32, ptr %.result, align 4
  ret i32 %3
}

define noundef i32 @BlockResults() {
entry:
  %result = alloca i32, align 4
  %source = alloca i32, align 4
  %first = alloca i32, align 4
  %second = alloca i32, align 4
  %block = alloca i32, align 4
  %forwarded = alloca i32, align 4
  %saved = alloca i32, align 4
  store i32 11, ptr %source, align 4
  %0 = load i32, ptr %source, align 4
  store i32 %0, ptr %first, align 4
  %call = call noundef i32 @Replace(ptr noundef nonnull align 4 dereferenceable(4) %source)
  store i32 %call, ptr %second, align 4
  %1 = load i32, ptr %first, align 4
  store i32 %1, ptr %saved, align 4
  %2 = load i32, ptr %saved, align 4
  store i32 %2, ptr %block, align 4
  %3 = load i32, ptr %block, align 4
  store i32 %3, ptr %forwarded, align 4
  %4 = load i32, ptr %forwarded, align 4
  store i32 %4, ptr %result, align 4
  %5 = load i32, ptr %result, align 4
  ret i32 %5
}

define noundef i32 @BranchResults(i1 noundef zeroext %flag) {
entry:
  %.result = alloca i32, align 4
  %flag.addr = alloca i8, align 1
  %first = alloca i32, align 4
  %second = alloca i32, align 4
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  store i32 7, ptr %first, align 4
  %1 = load i32, ptr %first, align 4
  store i32 %1, ptr %second, align 4
  br label %if.end

if.else:                                          ; preds = %entry
  store i32 11, ptr %first, align 4
  %2 = load i32, ptr %first, align 4
  store i32 %2, ptr %second, align 4
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %3 = load i32, ptr %second, align 4
  store i32 %3, ptr %.result, align 4
  %4 = load i32, ptr %.result, align 4
  ret i32 %4
}
