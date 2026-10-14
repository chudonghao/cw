define noundef i32 @"cw:IntegerCopy:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %source = alloca i32, align 4
  %copied = alloca i32, align 4
  store i32 17, ptr %source, align 4
  %0 = load i32, ptr %source, align 4
  store i32 %0, ptr %copied, align 4
  store i32 29, ptr %source, align 4
  %1 = load i32, ptr %copied, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @"cw:NegativeInteger:func()i32"() {
entry:
  %.result = alloca i32, align 4
  store i32 -1, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
