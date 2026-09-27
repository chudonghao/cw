double Widen(float value) { return static_cast<double>(value); }

float Narrow(double value) { return static_cast<float>(value); }

float SignedSingle(long value) { return static_cast<float>(value); }

float UnsignedSingle(unsigned long value) { return static_cast<float>(value); }

double SignedDouble(int value) { return static_cast<double>(value); }

double UnsignedDouble(unsigned int value) { return static_cast<double>(value); }

float SignedByte(signed char value) { return static_cast<float>(value); }

double UnsignedByte(unsigned char value) { return static_cast<double>(value); }

float RoundedInteger() { return 16777217; }

double NegativeInteger() { return -16777217; }

float NarrowOverflow() { return static_cast<float>(1e40); }

float NarrowUnderflow() { return static_cast<float>(-1e-300); }

float NarrowSubnormal() { return static_cast<float>(1.401298464324817e-45); }
