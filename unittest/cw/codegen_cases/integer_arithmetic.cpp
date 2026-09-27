// CW wraps signed arithmetic. C++ signed overflow is undefined, so the ordinary
// expression below only corresponds to CW when its intermediate results fit.
int IntegerArithmetic(int left, int right) { return (+left + -right) * (left - right); }

// Unsigned arithmetic and representable signed conversions express the CW
// constant results without invoking C++ signed overflow.
int AddWrap() { return -1 - static_cast<int>(~(2147483647u + 1u)); }

int SubtractWrap() { return static_cast<int>(2147483648u - 1u); }

int MultiplyWrap() { return static_cast<int>(65536u * 65536u); }

int NegateMinimum() { return -1 - static_cast<int>(~(0u - 2147483648u)); }
