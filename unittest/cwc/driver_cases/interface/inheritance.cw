namespace shapes {
  export trivial struct Origin {
    x i32;
  }
  export trivial struct Size {
    width i32;
  }
  export trivial struct Box : Origin, Size {}
}
export trivial struct Labeled : shapes::Box {
  label u8;
}
