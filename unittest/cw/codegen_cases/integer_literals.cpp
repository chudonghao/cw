// CW character literals are u8. C++ integer promotions and explicit casts express the same byte results.

long long SignedLiteral() { return 2147483648LL; }

unsigned long long UnsignedLiteral() { return 18446744073709551615ULL; }

long long MinimumLiteral() { return (-9223372036854775807LL - 1); }

unsigned short CharacterValue() { return static_cast<unsigned char>('\xFF'); }

unsigned char CharacterArithmetic() { return static_cast<unsigned char>(255u + 1u); }

unsigned char TruncatedLiteral() { return static_cast<unsigned char>(257); }

unsigned long long NegativeUnsignedLiteral() { return static_cast<unsigned long long>(-1); }

unsigned long long InferredLiteral() {
  auto value = 9223372036854775808ULL;
  return value;
}

signed char ByteMinimum() { return -128; }

// CW i8 negation wraps; Clang's signed char conversion gives the same result on this target.
signed char TypedNegation() { return static_cast<signed char>(-static_cast<signed char>(-128)); }

unsigned short HexadecimalSuffix() { return 0x1f32; }

unsigned long long ExplicitUnsigned() { return 18446744073709551615ULL; }

long long WidenedByte() { return static_cast<signed char>(-128); }

unsigned long NextIndex(unsigned long index) { return index + 1UL; }

long MinimumSize() { return (-9223372036854775807L - 1); }
