struct VirtualInterfacePointerTarget {
  virtual {
    abstract func Draw(this copy VirtualInterfacePointerTarget, value i32) i32;
  }
}

func Draw(object copy VirtualInterfacePointerTarget, value i32) i32 {
  value
}

ctor VirtualInterfacePointerTarget() {}

dtor VirtualInterfacePointerTarget() {}

func VirtualInterfacePointer(object copy VirtualInterfacePointerTarget) i32 {
  var direct *func (copy VirtualInterfacePointerTarget, i32) i32 := &Draw;
  var slot virtual *func (copy VirtualInterfacePointerTarget, i32) i32 := &Draw;

  direct(object, 1) + slot(object, 2)
}
