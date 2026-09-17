struct ConstructionValue {}

ctor ConstructionValue(value i32) {}

dtor ConstructionValue() {}

func Construction(address *ConstructionValue, argument i16) {
  var value := ConstructionValue(argument);
  ctor (address) ConstructionValue(argument);
}
