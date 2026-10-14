@"cw:str" = private constant [3 x i8] c"abc", align 1
@"cw:str.1" = private constant [3 x i8] c"a\00b", align 1
@"cw:str.2" = private constant [3 x i8] c"a\00c", align 1
@"cw:str.3" = private constant [4 x i8] c"abc\00", align 1
@"cw:str.4" = private constant [2 x i8] c"\FF\FE", align 1
@"cw:str.5" = private constant [3 x i8] c"\E4\B8\AD", align 1
@"cw:str.6" = private constant [2 x i8] c"\041", align 1
@"cw:str.7" = private constant [0 x i8] zeroinitializer, align 1
@"cw:str.8" = private constant [1 x i8] zeroinitializer, align 1

define noundef ptr @"cw:Plain:func()*const [3]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:Joined:func()*const [3]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:Embedded:func()*const [3]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str.1", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:EmbeddedOther:func()*const [3]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str.2", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:ExplicitEnd:func()*const [4]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str.3", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:Bytes:func()*const [2]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str.4", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:Text:func()*const [3]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str.5", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:SplitEscape:func()*const [2]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str.6", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:Empty:func()*const [0]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str.7", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @"cw:Zero:func()*const [1]u8"() {
entry:
  %.result = alloca ptr, align 8
  store ptr @"cw:str.8", ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}
