namespace api {
  trivial struct Index { value usize; }
  export func Read(value i32) i32 { value + 1 }
  export func Read(value i64) i32 { 20 }
  export func Read(value isize) i32 { 30 }
  export func Pick(value &copy i32) i32 { 40 }
  export func Pick(value &mut i32) i32 { 50 }
  export func Pick(value &move i32) i32 { 60 }
  export func Apply(callback *func(i64) i32, value i64) i32 { callback(value) }
  export func Array(value &copy [2 + 2] i32) i32 { var index := Index(); value[index.value] }
  export func 读取(value i32) i32 { value + 7 }
  export trivial struct Item { value i32; }
  export func operator+(left &copy Item, right i32) i32 { left.value + right }
  export func main(value i32) i32 { value + 3 }
}
