struct VirtualInterfacePointerTarget {
  virtual int Draw(int value) const = 0;
};

int VirtualInterfacePointerTarget::Draw(int value) const { return value; }

int Draw(const VirtualInterfacePointerTarget&, int value) { return value; }

int VirtualInterfacePointer(const VirtualInterfacePointerTarget& object) {
  int (*direct)(const VirtualInterfacePointerTarget&, int) = &Draw;
  int (VirtualInterfacePointerTarget::*slot)(int) const = &VirtualInterfacePointerTarget::Draw;
  return direct(object, 1) + (object.*slot)(2);
}
