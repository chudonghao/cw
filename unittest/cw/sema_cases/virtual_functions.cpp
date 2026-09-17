struct VirtualFunctions {
  virtual void Draw() const;
  virtual void Measure() const = 0;
};

void VirtualFunctions::Draw() const {}

void Use(const VirtualFunctions& object) {
  object.Draw();
  object.Measure();
}
