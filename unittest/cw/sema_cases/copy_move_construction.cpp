struct CopyMove {
  int value;

  CopyMove(int value) : value(value) {}
  CopyMove(const CopyMove& other) : value(other.value) {}
  CopyMove(CopyMove&& other) : value(other.value) {}
  ~CopyMove() {}
};

CopyMove MakeCopyMove() { return CopyMove(1); }

CopyMove CopyMoveConstruction(CopyMove& source, bool condition) {
  CopyMove copied = source;
  CopyMove moved = static_cast<CopyMove&&>(source);
  CopyMove direct = MakeCopyMove();
  return condition ? copied : static_cast<CopyMove&&>(moved);
}

struct CopyOnly {
  int value;

  CopyOnly(int value) : value(value) {}
  CopyOnly(const CopyOnly& other) : value(other.value) {}
  ~CopyOnly() {}
};

CopyOnly CopyFallback(CopyOnly& source) {
  return static_cast<CopyOnly&&>(source);
}
