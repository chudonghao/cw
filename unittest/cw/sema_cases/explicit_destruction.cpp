struct DestructionValue {
  DestructionValue() {}
  ~DestructionValue() {}
};
void ExplicitDestruction(DestructionValue* address, const DestructionValue* const_address) {
  address->~DestructionValue();
  const_address->~DestructionValue();
}
