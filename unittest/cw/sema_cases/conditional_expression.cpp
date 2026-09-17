void Observe() {}

void ConditionalExpression(bool condition, short signed16, int signed32, unsigned int unsigned32,
                           float single, double wide) {
  auto same_bool = condition ? true : false;
  auto wider_integer = condition ? signed16 : signed32;
  auto mixed_sign = condition ? signed32 : unsigned32;
  auto mixed_float = condition ? signed16 : single;
  auto wider_float = condition ? single : wide;
  condition ? Observe() : Observe();
}
