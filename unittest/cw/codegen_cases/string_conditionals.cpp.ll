; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names string_conditionals.cpp -o -
; ModuleID = 'string_conditionals.cpp'
source_filename = "string_conditionals.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Array = type { [3 x i8] }

@_ZL3Yes = internal constant %struct.Array { [3 x i8] c"yes" }, align 1
@_ZL2No = internal constant %struct.Array { [3 x i8] c"no!" }, align 1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 1 dereferenceable(3) ptr @_Z6Chooseb(i1 noundef zeroext %flag) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ @_ZL3Yes, %cond.true ], [ @_ZL2No, %cond.false ]
  ret ptr %cond
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z10ReadChoicebm(i1 noundef zeroext %flag, i64 noundef %index) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %index.addr = alloca i64, align 8
  %text = alloca %struct.Array, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i64 %index, ptr %index.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ @_ZL3Yes, %cond.true ], [ @_ZL2No, %cond.false ]
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %text, ptr align 1 %cond, i64 3, i1 false)
  %values = getelementptr inbounds nuw %struct.Array, ptr %text, i32 0, i32 0
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [3 x i8], ptr %values, i64 0, i64 %1
  %2 = load i8, ptr %arrayidx, align 1
  ret i8 %2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i8 @_Z9WithValuebm(i1 noundef zeroext %flag, i64 noundef %index) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %index.addr = alloca i64, align 8
  %text = alloca %struct.Array, align 1
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store i64 %index, ptr %index.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  call void @llvm.memcpy.p0.p0.i64(ptr align 1 %text, ptr align 1 @_ZL3Yes, i64 3, i1 false)
  br label %cond.end

cond.false:                                       ; preds = %entry
  %values = getelementptr inbounds nuw %struct.Array, ptr %text, i32 0, i32 0
  store i8 110, ptr %values, align 1
  %arrayinit.element = getelementptr inbounds i8, ptr %values, i64 1
  store i8 111, ptr %arrayinit.element, align 1
  %arrayinit.element1 = getelementptr inbounds i8, ptr %values, i64 2
  store i8 33, ptr %arrayinit.element1, align 1
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %values2 = getelementptr inbounds nuw %struct.Array, ptr %text, i32 0, i32 0
  %1 = load i64, ptr %index.addr, align 8
  %arrayidx = getelementptr inbounds nuw [3 x i8], ptr %values2, i64 0, i64 %1
  %2 = load i8, ptr %arrayidx, align 1
  ret i8 %2
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 1 dereferenceable(3) ptr @_Z5TouchRj(ptr noundef nonnull align 4 dereferenceable(4) %count) #0 {
entry:
  %count.addr = alloca ptr, align 8
  store ptr %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %count.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %count.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  ret ptr @_ZL2No
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z7DiscardbRj(i1 noundef zeroext %flag, ptr noundef nonnull align 4 dereferenceable(4) %count) #0 {
entry:
  %flag.addr = alloca i8, align 1
  %count.addr = alloca ptr, align 8
  %storedv = zext i1 %flag to i8
  store i8 %storedv, ptr %flag.addr, align 1
  store ptr %count, ptr %count.addr, align 8
  %0 = load i8, ptr %flag.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  br label %cond.end

cond.false:                                       ; preds = %entry
  %1 = load ptr, ptr %count.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 1 dereferenceable(3) ptr @_Z5TouchRj(ptr noundef nonnull align 4 dereferenceable(4) %1)
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi ptr [ @_ZL3Yes, %cond.true ], [ %call, %cond.false ]
  ret void
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
