@.str = private constant [3 x i8] c"abc", align 1
@.str.1 = private constant [3 x i8] c"a\00b", align 1
@.str.2 = private constant [3 x i8] c"a\00c", align 1
@.str.3 = private constant [4 x i8] c"abc\00", align 1
@.str.4 = private constant [2 x i8] c"\FF\FE", align 1
@.str.5 = private constant [3 x i8] c"\E4\B8\AD", align 1
@.str.6 = private constant [2 x i8] c"\041", align 1
@.str.7 = private constant [0 x i8] zeroinitializer, align 1
@.str.8 = private constant [1 x i8] zeroinitializer, align 1

define noundef ptr @Plain() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @Joined() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @Embedded() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str.1, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @EmbeddedOther() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str.2, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @ExplicitEnd() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str.3, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @Bytes() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str.4, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @Text() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str.5, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @SplitEscape() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str.6, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @Empty() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str.7, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}

define noundef ptr @Zero() {
entry:
  %.result = alloca ptr, align 8
  store ptr @.str.8, ptr %.result, align 8
  %0 = load ptr, ptr %.result, align 8
  ret ptr %0
}
