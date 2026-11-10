; Reference compiler: Homebrew clang version 23.1.5
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names else_if_branches.cpp -o -
; ModuleID = 'else_if_branches.cpp'
source_filename = "else_if_branches.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Token = type { i8 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef zeroext i1 @_Z5ReadyRK5Token(ptr noundef nonnull align 1 dereferenceable(1) %token) #0 {
entry:
  %token.addr = alloca ptr, align 8
  store ptr %token, ptr %token.addr, align 8
  ret i1 true
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z14StatementChainbb(i1 noundef zeroext %first, i1 noundef zeroext %second) #1 {
entry:
  %first.addr = alloca i8, align 1
  %second.addr = alloca i8, align 1
  %a = alloca %struct.Token, align 1
  %b = alloca %struct.Token, align 1
  %c = alloca %struct.Token, align 1
  %storedv = zext i1 %first to i8
  store i8 %storedv, ptr %first.addr, align 1
  %storedv1 = zext i1 %second to i8
  store i8 %storedv1, ptr %second.addr, align 1
  %0 = load i8, ptr %first.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %a)
  %call2 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %a) #2
  br label %if.end10

if.else:                                          ; preds = %entry
  %1 = load i8, ptr %second.addr, align 1
  %loadedv3 = icmp ne i8 %1, 0
  br i1 %loadedv3, label %if.then4, label %if.else7

if.then4:                                         ; preds = %if.else
  %call5 = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %b)
  %call6 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %b) #2
  br label %if.end

if.else7:                                         ; preds = %if.else
  %call8 = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %c)
  %call9 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %c) #2
  br label %if.end

if.end:                                           ; preds = %if.else7, %if.then4
  br label %if.end10

if.end10:                                         ; preds = %if.end, %if.then
  ret void
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5TokenC2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN5TokenD2Ev(ptr noundef nonnull align 1 dereferenceable(1) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z11ResultChainbb(i1 noundef zeroext %first, i1 noundef zeroext %second) #0 {
entry:
  %retval = alloca i32, align 4
  %first.addr = alloca i8, align 1
  %second.addr = alloca i8, align 1
  %storedv = zext i1 %first to i8
  store i8 %storedv, ptr %first.addr, align 1
  %storedv1 = zext i1 %second to i8
  store i8 %storedv1, ptr %second.addr, align 1
  %0 = load i8, ptr %first.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  store i32 1, ptr %retval, align 4
  br label %return

if.else:                                          ; preds = %entry
  %1 = load i8, ptr %second.addr, align 1
  %loadedv2 = icmp ne i8 %1, 0
  br i1 %loadedv2, label %if.then3, label %if.else4

if.then3:                                         ; preds = %if.else
  store i32 2, ptr %retval, align 4
  br label %return

if.else4:                                         ; preds = %if.else
  store i32 3, ptr %retval, align 4
  br label %return

return:                                           ; preds = %if.else4, %if.then3, %if.then
  %2 = load i32, ptr %retval, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z18ConditionTemporaryb(i1 noundef zeroext %first) #1 {
entry:
  %first.addr = alloca i8, align 1
  %ref.tmp = alloca %struct.Token, align 1
  %storedv = zext i1 %first to i8
  store i8 %storedv, ptr %first.addr, align 1
  %0 = load i8, ptr %first.addr, align 1
  %loadedv = icmp ne i8 %0, 0
  br i1 %loadedv, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  br label %if.end4

if.else:                                          ; preds = %entry
  %call = call noundef ptr @_ZN5TokenC1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  %call1 = call noundef zeroext i1 @_Z5ReadyRK5Token(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp)
  %call2 = call noundef ptr @_ZN5TokenD1Ev(ptr noundef nonnull align 1 dereferenceable(1) %ref.tmp) #2
  br i1 %call1, label %if.then3, label %if.end

if.then3:                                         ; preds = %if.else
  br label %if.end

if.end:                                           ; preds = %if.then3, %if.else
  br label %if.end4

if.end4:                                          ; preds = %if.end, %if.then
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenC2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN5TokenD2Ev(ptr noundef nonnull returned align 1 dereferenceable(1) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  ret ptr %this1
}

attributes #0 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 4]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.5"}
