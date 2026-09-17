struct VirtualFunctions {
  virtual {
    func Draw(this copy VirtualFunctions);
    abstract func Measure(receiver copy VirtualFunctions);
  }
}

func Draw(object copy VirtualFunctions) {}

ctor VirtualFunctions() {}

dtor VirtualFunctions() {}

func Use(object copy VirtualFunctions) {
  object.Draw();
  object.Measure();
}
