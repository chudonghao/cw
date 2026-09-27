bool Equal(float left, float right) { return left == right; }

bool NotEqual(double left, double right) { return left != right; }

bool Less(float left, float right) { return left < right; }

bool LessEqual(double left, double right) { return left <= right; }

bool Greater(float left, float right) { return left > right; }

bool GreaterEqual(double left, double right) { return left >= right; }

bool MixedLess(int left, double right) { return left < right; }

bool NaNEqual() { return (0.0 / 0.0) == 1.0; }

bool NaNNotEqual() { return (0.0 / 0.0) != 1.0; }

bool NaNLess() { return (0.0 / 0.0) < 1.0; }

bool NaNLessEqual() { return (0.0 / 0.0) <= 1.0; }

bool NaNGreater() { return (0.0 / 0.0) > 1.0; }

bool NaNGreaterEqual() { return (0.0 / 0.0) >= 1.0; }

bool SignedZerosEqual() { return 0.0f == -0.0f; }
