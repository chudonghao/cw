; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names explicit_lifetime.cpp -o -
; ModuleID = 'explicit_lifetime.cpp'
source_filename = "explicit_lifetime.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%struct.Item = type { i32 }

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef ptr @_Z6TargetP4Item(ptr noundef %address) #0 {
entry:
  %address.addr = alloca ptr, align 8
  store ptr %address, ptr %address.addr, align 8
  %0 = load ptr, ptr %address.addr, align 8
  ret ptr %0
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef i32 @_Z8Argumenti(i32 noundef %value) #0 {
entry:
  %value.addr = alloca i32, align 4
  store i32 %value, ptr %value.addr, align 4
  %0 = load i32, ptr %value.addr, align 4
  ret i32 %0
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef ptr @_Z11ConstructAtP4Itemi(ptr noundef %address, i32 noundef %value) #1 {
entry:
  %address.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %address, ptr %address.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %0 = load ptr, ptr %address.addr, align 8
  %call = call noundef ptr @_Z6TargetP4Item(ptr noundef %0)
  %1 = load i32, ptr %value.addr, align 4
  %call1 = call noundef i32 @_Z8Argumenti(i32 noundef %1)
  %call2 = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef %call1)
  ret ptr %call
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %value) unnamed_addr #1 {
entry:
  %this.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %0 = load i32, ptr %value.addr, align 4
  %call = call noundef ptr @_ZN4ItemC2Ei(ptr noundef nonnull align 4 dereferenceable(4) %this1, i32 noundef %0)
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define void @_Z9DestroyAtPK4Item(ptr noundef %address) #0 {
entry:
  %address.addr = alloca ptr, align 8
  store ptr %address, ptr %address.addr, align 8
  %0 = load ptr, ptr %address.addr, align 8
  %call = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %0) #2
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %call = call noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %this1) #2
  ret ptr %this1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_Z6ManualP4Item(ptr noundef %address) #1 {
entry:
  %address.addr = alloca ptr, align 8
  store ptr %address, ptr %address.addr, align 8
  %0 = load ptr, ptr %address.addr, align 8
  %call = call noundef ptr @_Z6TargetP4Item(ptr noundef %0)
  %call1 = call noundef i32 @_Z8Argumenti(i32 noundef 1)
  %call2 = call noundef ptr @_ZN4ItemC1Ei(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef %call1)
  %1 = load ptr, ptr %address.addr, align 8
  %call3 = call noundef ptr @_Z6TargetP4Item(ptr noundef %1)
  %call4 = call noundef ptr @_ZN4ItemD1Ev(ptr noundef nonnull align 4 dead_on_return(4) dereferenceable(4) %call3) #2
  ret void
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemC2Ei(ptr noundef nonnull returned align 4 dereferenceable(4) %this, i32 noundef %value) unnamed_addr #0 {
entry:
  %this.addr = alloca ptr, align 8
  %value.addr = alloca i32, align 4
  store ptr %this, ptr %this.addr, align 8
  store i32 %value, ptr %value.addr, align 4
  %this1 = load ptr, ptr %this.addr, align 8
  %value2 = getelementptr inbounds nuw %struct.Item, ptr %this1, i32 0, i32 0
  %0 = load i32, ptr %value.addr, align 4
  store i32 %0, ptr %value2, align 4
  ret ptr %this1
}

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define linkonce_odr noundef ptr @_ZN4ItemD2Ev(ptr noundef nonnull returned align 4 dead_on_return(4) dereferenceable(4) %this) unnamed_addr #0 {
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

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
