namespace api {
export struct Box { value i32; }
export ctor Box(value i32) { this.value := value; }
export dtor Box() {}
export func operator=(target &mut Box, source i32) &mut Box { target.value = source; target }
export func operator=(target &mut Box, source &copy Box) { target.value = source.value; }
}
