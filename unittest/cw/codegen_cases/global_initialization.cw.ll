%struct.Record = type { i32 }

@number = global i32 0, align 4
@first = global i32 0, align 4
@second = global i32 0, align 4
@enabled = global i8 0, align 1
@saved = global i32 0, align 4
@address = global ptr null, align 8
@action = global ptr null, align 8
@text = global [2 x i8] zeroinitializer, align 1
@record = global %struct.Record zeroinitializer, align 4
@.str = private constant [2 x i8] c"hi", align 1
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @.cw.global_init, ptr null }]

define noundef i32 @Read() {
entry:
  %.result = alloca i32, align 4
  %0 = load i32, ptr @number, align 4
  store i32 %0, ptr %.result, align 4
  %1 = load i32, ptr %.result, align 4
  ret i32 %1
}

define noundef i32 @Advance() {
entry:
  %.result = alloca i32, align 4
  %0 = load i32, ptr @number, align 4
  %add = add i32 %0, 1
  store i32 %add, ptr @number, align 4
  %1 = load i32, ptr @number, align 4
  store i32 %1, ptr %.result, align 4
  %2 = load i32, ptr %.result, align 4
  ret i32 %2
}

define noundef i32 @Update() {
entry:
  %.result = alloca i32, align 4
  %0 = load ptr, ptr @action, align 8
  %call = call noundef i32 %0()
  %1 = load ptr, ptr @address, align 8
  store i32 %call, ptr %1, align 4
  %2 = load i32, ptr @second, align 4
  store i32 %2, ptr @record, align 4
  %3 = load i32, ptr @first, align 4
  %4 = load i32, ptr @record, align 4
  %add = add i32 %3, %4
  store i32 %add, ptr %.result, align 4
  %5 = load i32, ptr %.result, align 4
  ret i32 %5
}

define internal void @.cw.global_var_init() {
entry:
  store i32 7, ptr @number, align 4
  ret void
}

define internal void @.cw.global_var_init.1() {
entry:
  %call = call noundef i32 @Advance()
  store i32 %call, ptr @first, align 4
  %call1 = call noundef i32 @Advance()
  store i32 %call1, ptr @second, align 4
  ret void
}

define internal void @.cw.global_var_init.2() {
entry:
  store i8 1, ptr @enabled, align 1
  %call = call noundef i32 @Read()
  store i32 %call, ptr @saved, align 4
  ret void
}

define internal void @.cw.global_var_init.3() {
entry:
  store ptr @number, ptr @address, align 8
  ret void
}

define internal void @.cw.global_var_init.4() {
entry:
  store ptr @Read, ptr @action, align 8
  ret void
}

define internal void @.cw.global_var_init.5() {
entry:
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 @text, ptr align 1 @.str, i64 2, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

define internal void @.cw.global_var_init.6() {
entry:
  call void @llvm.memset.p0.i64(ptr align 4 @record, i8 0, i64 4, i1 false)
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

define internal void @.cw.global_init() {
entry:
  call void @.cw.global_var_init()
  call void @.cw.global_var_init.1()
  call void @.cw.global_var_init.2()
  call void @.cw.global_var_init.3()
  call void @.cw.global_var_init.4()
  call void @.cw.global_var_init.5()
  call void @.cw.global_var_init.6()
  ret void
}

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }
