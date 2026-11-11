%struct.Nothing = type { i8 }
%struct.Vector = type { %struct.X, %struct.Y, float }
%struct.X = type { float }
%struct.Y = type { float }
%struct.Links = type { %struct.Head, %struct.Tail }
%struct.Head = type { ptr }
%struct.Tail = type { ptr }
%struct.Marked = type { %struct.Head, ptr }

define void @"cw:PassNothing:func(Nothing)Nothing"() {
entry:
  %.result = alloca %struct.Nothing, align 1
  %value = alloca %struct.Nothing, align 1
  ret void
}

define %struct.Vector @"cw:PassVector:func(Vector)Vector"([3 x float] %value.coerce) {
entry:
  %.result = alloca %struct.Vector, align 4
  %value = alloca %struct.Vector, align 4
  store [3 x float] %value.coerce, ptr %value, align 4
  call void @llvm.memcpy.p0.p0.i64(ptr align 4 %.result, ptr align 4 %value, i64 12, i1 false)
  %0 = load %struct.Vector, ptr %.result, align 4
  ret %struct.Vector %0
}

define [2 x i64] @"cw:PassLinks:func(Links)Links"([2 x ptr] %value.coerce) {
entry:
  %.result = alloca %struct.Links, align 8
  %value = alloca %struct.Links, align 8
  store [2 x ptr] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %0
}

define [2 x i64] @"cw:PassMarked:func(Marked)Marked"([2 x i64] %value.coerce) {
entry:
  %.result = alloca %struct.Marked, align 8
  %value = alloca %struct.Marked, align 8
  store [2 x i64] %value.coerce, ptr %value, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %.result, ptr align 8 %value, i64 16, i1 false)
  %0 = load [2 x i64], ptr %.result, align 8
  ret [2 x i64] %0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
