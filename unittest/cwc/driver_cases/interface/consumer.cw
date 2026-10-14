export func Consume() i32 {
  var handle := Handle(7);
  var point := Point();
  var sum := point + point;
  Flush();
  Read(handle) + Add(sum.x, 2)
}
