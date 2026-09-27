const int* Readonly(int* value) { return value; }

const int* const* DeepReadonly(int** value) { return value; }

int* ReadReference(int* const& value) { return value; }

int*& ForwardReference(int*& value) { return value; }

void Replace(int*& target, int* source) { target = source; }

bool Take(int* const& left, int*&& right) { return left == right; }

bool Temporary() { return Take(nullptr, nullptr); }
