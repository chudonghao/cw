struct DestructionValue {}

ctor DestructionValue() {}

dtor DestructionValue() {}

func ExplicitDestruction(address *DestructionValue, const_address *const DestructionValue) {
  dtor (address) DestructionValue();
  dtor (const_address) DestructionValue();
}
