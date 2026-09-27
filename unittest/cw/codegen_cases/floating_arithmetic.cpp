#pragma clang fp contract(off)

float SingleArithmetic(float left, float right) { return (+left + -right) * (left - right) / right; }

double DoubleArithmetic(double left, double right) { return (+left + -right) * (left - right) / right; }

double MultiplyAdd(double left, double right, double addend) { return left * right + addend; }

float Grouped(float first, float second, float third) { return first + (second + third); }

double PositiveInfinity() { return 1.0 / 0.0; }

float NegativeInfinity() { return 1.0f / -0.0f; }

double Overflow() { return 1e308 * 10.0; }

double NegativeUnderflow() { return -1e-300 * 1e-300; }

float GradualUnderflow() { return 1.1754943508222875e-38f * 0.5f; }

float RoundEachStep() { return (16777216.0f + 1.0f) - 16777216.0f; }
