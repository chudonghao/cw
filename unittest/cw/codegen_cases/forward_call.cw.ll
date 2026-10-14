define noundef i32 @"cw:ForwardCall:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %call = call noundef i32 @"cw:Later:func()i32"()
  store i32 %call, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @"cw:Later:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 37, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
