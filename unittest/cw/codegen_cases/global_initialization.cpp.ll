; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names global_initialization.cpp -o -
; ModuleID = 'global_initialization.cpp'
source_filename = "global_initialization.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Record = type { i32 }

@number = global i32 7, align 4
@first = global i32 0, align 4
@second = global i32 0, align 4
@enabled = global i8 1, align 1
@_ZL5saved = internal global i32 0, align 4
@address = global ptr @number, align 8
@action = global ptr @_Z4Readv, align 8
@text = global [2 x i8] c"hi", align 1
@record = global %struct.Record zeroinitializer, align 4
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @_GLOBAL__sub_I_global_initialization.cpp, ptr null }]

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z4Readv() #0 {
entry:
  %0 = load i32, ptr @number, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z7Advancev() #0 {
entry:
  %0 = load i32, ptr @number, align 4
  %add = add nsw i32 %0, 1
  store i32 %add, ptr @number, align 4
  %1 = load i32, ptr @number, align 4
  ret i32 %1
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_var_init() #1 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  %call = call noundef i32 @_Z7Advancev()
  store i32 %call, ptr @first, align 4
  ret void
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_var_init.1() #1 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  %call = call noundef i32 @_Z7Advancev()
  store i32 %call, ptr @second, align 4
  ret void
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @__cxx_global_var_init.2() #1 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  %call = call noundef i32 @_Z4Readv()
  store i32 %call, ptr @_ZL5saved, align 4
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_Z6Updatev() #2 {
entry:
  %0 = load ptr, ptr @action, align 8
  %call = call noundef i32 %0()
  %1 = load ptr, ptr @address, align 8
  store i32 %call, ptr %1, align 4
  %2 = load i32, ptr @second, align 4
  store i32 %2, ptr @record, align 4
  %3 = load i32, ptr @first, align 4
  %4 = load i32, ptr @record, align 4
  %add = add nsw i32 %3, %4
  ret i32 %add
}

; Function Attrs: noinline ssp uwtable(sync)
define internal void @_GLOBAL__sub_I_global_initialization.cpp() #1 section "__TEXT,__StaticInit,regular,pure_instructions" {
entry:
  call void @__cxx_global_var_init()
  call void @__cxx_global_var_init.1()
  call void @__cxx_global_var_init.2()
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { noinline ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
