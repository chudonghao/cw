struct CopyMove {
  value i32;
}

ctor CopyMove(value i32) {
  this.value := value;
}

ctor CopyMove(other copy CopyMove) {
  this.value := other.value;
}

ctor CopyMove(other move CopyMove) {
  this.value := other.value;
}

dtor CopyMove() {}

func MakeCopyMove() CopyMove {
  CopyMove(1)
}

func CopyMoveConstruction(source mut CopyMove, condition bool) CopyMove {
  var copied CopyMove := source;
  var moved CopyMove := move source;
  var direct CopyMove := MakeCopyMove();

  return condition ? copied : move moved;
}

struct CopyOnly {
  value i32;
}

ctor CopyOnly(value i32) {
  this.value := value;
}

ctor CopyOnly(other copy CopyOnly) {
  this.value := other.value;
}

dtor CopyOnly() {}

func CopyFallback(source mut CopyOnly) CopyOnly {
  return move source;
}
