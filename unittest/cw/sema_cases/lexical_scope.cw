func LexicalScope(value i32) void {
  value;

  {
    var value i32 := 0;
    value;
  }

  value;
}
