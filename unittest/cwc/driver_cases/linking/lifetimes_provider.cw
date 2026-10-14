namespace lifetime {
  var count i32 := 0;
  export func Count() i32 { count }
  export struct Base { value i32; }
  export ctor Base(value i32) { this.value := value; count = count + 1; }
  export ctor Base() { this := Base(7); }
  export ctor Base(other &copy Base) { this.value := other.value; count = count + 1; }
  export dtor Base() { count = count - 1; }
}
