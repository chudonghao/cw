func Replace(value &mut i32) i32 {
  value = 71;
  value
}

func BlockResults() var result i32 {
  var source i32;
  source := 11;
  var first i32, second i32 := source, Replace(source);
  var block i32, forwarded i32 := {
    var saved i32 := first;
    saved, block
  }
  result := forwarded;
  return;
}

func BranchResults(flag bool) i32 {
  var first i32, second i32 := {
    if flag {
      7, first
    } else {
      11, first
    }
  }
  second
}
