; Reference compiler: Homebrew clang version 23.1.1
; Reference command: clang++ --target=arm64-apple-darwin25.6.0 -std=c++17 -O0 -g0 -S -emit-llvm -fno-discard-value-names increment_operators.cpp -o -
; ModuleID = 'increment_operators.cpp'
source_filename = "increment_operators.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx26.0.0"

%"struct.Api::Value" = type { i32 }

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_ZN3Api6PrefixERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApippERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %0)
  ret ptr %call
}

declare noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApippERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4)) #1

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_ZN3Api7PostfixERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %retval = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call i32 @_ZN3ApippERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 0)
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %coerce.dive1 = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  %1 = load i32, ptr %coerce.dive1, align 4
  ret i32 %1
}

declare i32 @_ZN3ApippERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4), i32 noundef) #1

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define noundef i32 @_ZN3Api7ByValueENS_5ValueE(i64 %value.coerce) #0 {
entry:
  %value = alloca %"struct.Api::Value", align 4
  %agg.tmp = alloca %"struct.Api::Value", align 4
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %value, i32 0, i32 0
  %coerce.val.ii = trunc i64 %value.coerce to i32
  store i32 %coerce.val.ii, ptr %coerce.dive, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %agg.tmp, ptr align 4 %value, i64 4, i1 false)
  %coerce.dive1 = getelementptr inbounds nuw %"struct.Api::Value", ptr %agg.tmp, i32 0, i32 0
  %0 = load i32, ptr %coerce.dive1, align 4
  %coerce.val.ii2 = zext i32 %0 to i64
  %call = call noundef i32 @_ZN3ApimmENS_5ValueE(i64 %coerce.val.ii2)
  ret i32 %call
}

declare noundef i32 @_ZN3ApimmENS_5ValueE(i64) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #2

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define void @_ZN3Api7DiscardERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  call void @_ZN3ApimmEONS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef 0)
  ret void
}

declare void @_ZN3ApimmEONS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4), i32 noundef) #1

; Function Attrs: mustprogress noinline nounwind optnone ssp uwtable(sync)
define noundef nonnull align 4 dereferenceable(4) ptr @_ZN3Api6LocateERNS_5ValueERi(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %count) #3 {
entry:
  %value.addr = alloca ptr, align 8
  %count.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %count.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %0, align 4
  %add = add i32 %1, 1
  %2 = load ptr, ptr %count.addr, align 8, !nonnull !5, !align !6
  store i32 %add, ptr %2, align 4
  %3 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  ret ptr %3
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_ZN3Api4OnceERNS_5ValueERi(ptr noundef nonnull align 4 dereferenceable(4) %value, ptr noundef nonnull align 4 dereferenceable(4) %count) #0 {
entry:
  %retval = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  %count.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store ptr %count, ptr %count.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load ptr, ptr %count.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN3Api6LocateERNS_5ValueERi(ptr noundef nonnull align 4 dereferenceable(4) %0, ptr noundef nonnull align 4 dereferenceable(4) %1)
  %call1 = call i32 @_ZN3ApippERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef 0)
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  store i32 %call1, ptr %coerce.dive, align 4
  %coerce.dive2 = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  %2 = load i32, ptr %coerce.dive2, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_ZN3Api6NestedERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %value) #0 {
entry:
  %retval = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN3ApippERNS_5ValueE(ptr noundef nonnull align 4 dereferenceable(4) %0)
  %call1 = call i32 @_ZN3ApippERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %call, i32 noundef 0)
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  store i32 %call1, ptr %coerce.dive, align 4
  %coerce.dive2 = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  %1 = load i32, ptr %coerce.dive2, align 4
  ret i32 %1
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_Z8ExplicitRN3Api5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %value, i32 noundef %marker) #0 {
entry:
  %retval = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  %marker.addr = alloca i32, align 4
  store ptr %value, ptr %value.addr, align 8
  store i32 %marker, ptr %marker.addr, align 4
  %0 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %1 = load i32, ptr %marker.addr, align 4
  %call = call i32 @_ZN3ApippERNS_5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %0, i32 noundef %1)
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %coerce.dive1 = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  %2 = load i32, ptr %coerce.dive1, align 4
  ret i32 %2
}

; Function Attrs: mustprogress noinline optnone ssp uwtable(sync)
define i32 @_Z8IndirectRN3Api5ValueEi(ptr noundef nonnull align 4 dereferenceable(4) %value, i32 noundef %marker) #0 {
entry:
  %retval = alloca %"struct.Api::Value", align 4
  %value.addr = alloca ptr, align 8
  %marker.addr = alloca i32, align 4
  %operation = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  store i32 %marker, ptr %marker.addr, align 4
  store ptr @_ZN3ApippERNS_5ValueEi, ptr %operation, align 8
  %0 = load ptr, ptr %operation, align 8
  %1 = load ptr, ptr %value.addr, align 8, !nonnull !5, !align !6
  %2 = load i32, ptr %marker.addr, align 4
  %call = call i32 %0(ptr noundef nonnull align 4 dereferenceable(4) %1, i32 noundef %2)
  %coerce.dive = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  store i32 %call, ptr %coerce.dive, align 4
  %coerce.dive1 = getelementptr inbounds nuw %"struct.Api::Value", ptr %retval, i32 0, i32 0
  %3 = load i32, ptr %coerce.dive1, align 4
  ret i32 %3
}

attributes #0 = { mustprogress noinline optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { mustprogress noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 5]}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"uwtable", i32 1}
!3 = !{i32 7, !"frame-pointer", i32 4}
!4 = !{!"Homebrew clang version 23.1.1"}
!5 = !{}
!6 = !{i64 4}
