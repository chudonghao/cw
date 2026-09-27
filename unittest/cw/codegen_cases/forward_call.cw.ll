define noundef i32 @ForwardCall() {
entry:
  %.result = alloca i32, align 4
  %call = call noundef i32 @Later()
  store i32 %call, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define noundef i32 @Later() {
entry:
  %.result = alloca i32, align 4
  store i32 37, ptr %.result, align 4
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}
