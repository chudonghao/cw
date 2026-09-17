struct Base {
  value i32;
}

ctor Base(value i32) {
  this.value := value;
}

dtor Base() {}

struct SingleInheritance : Base {
  own i32;
}

ctor SingleInheritance(value i32) {
  this.Base := Base(value);
  this.own := value;
}

dtor SingleInheritance() {}

func ReadBase(value copy SingleInheritance) i32 {
  return value.Base.value;
}

func ReadBasePointer(value *SingleInheritance) i32 {
  return value->Base.value;
}

trivial struct Root {
  root i32;
}

trivial struct Middle : Root {}

trivial struct Leaf : Middle {}

func ReadIndirectBase(value copy Leaf) i32 {
  return value.Root.root;
}

func ReadExplicitBasePath(value copy Leaf) i32 {
  return value.Middle.Root.root;
}
