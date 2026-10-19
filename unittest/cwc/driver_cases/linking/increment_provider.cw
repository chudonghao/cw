namespace Steps {
export trivial struct Counter { value i32; }
export func operator++(counter &mut Counter) &mut Counter { ++counter.value; counter }
export func operator++(counter &mut Counter, marker i32) Counter {
  var old := counter; counter.value += marker + 1; old
}
export func operator--(counter &mut Counter) &mut Counter { --counter.value; counter }
export func operator--(counter &mut Counter, marker i32) Counter {
  var old := counter; counter.value -= marker + 1; old
}
}
