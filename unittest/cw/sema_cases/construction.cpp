struct ConstructionValue {
  ConstructionValue(int value) {}
  ~ConstructionValue() {}
};
void* operator new(__SIZE_TYPE__, void* address) noexcept;
void Construction(ConstructionValue* address, short argument) {
  ConstructionValue value(argument);
  ::new (address) ConstructionValue(argument);
}
