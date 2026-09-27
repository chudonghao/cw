struct VirtualInterfacePointerTarget {
  virtual int Draw(int value) const = 0;
};

int VirtualInterfacePointerTarget::Draw(int value) const { return value; }

// CW associates the ordinary Draw definition with its virtual interface.
// This adapter reaches the fixed member definition without virtual dispatch.
int Draw(const VirtualInterfacePointerTarget& object, int value) {
  return object.VirtualInterfacePointerTarget::Draw(value);
}

int VirtualInterfacePointer(const VirtualInterfacePointerTarget& object) {
  int (*direct)(const VirtualInterfacePointerTarget&, int) = &Draw;
  int (VirtualInterfacePointerTarget::*slot)(int) const = &VirtualInterfacePointerTarget::Draw;
  return direct(object, 1) + (object.*slot)(2);
}
