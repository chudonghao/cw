float Single(float value) { return value; }

double Double(double value) { return value; }

double Read(const double& value) { return value; }

float& Locate(float& value) { return value; }

void Assign(float& target, double source) { Locate(target) = static_cast<float>(source); }

double Forward(float value) { return Double(value); }

double Temporary() { return Read(0.5); }

float ReadMove(float&& value) { return value; }

float MoveLocal() {
  float value = 2.5f;
  return ReadMove(static_cast<float&&>(value));
}
