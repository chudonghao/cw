trivial struct Pair {
  first i32;
  second i32;
}

func Transform(value Pair, add i32) Pair {
  var result Pair := {
    result.first := value.first + add;
    result.second := value.second + add;
  }
  result
}

func main() i32 {
  var source Pair := {
    source.first := 4;
    source.second := 5;
  }
  var copied := Transform(source, 3);
  var target Pair := source;
  target = copied;
  target.first + target.second
}
