using Callback = int (*)(int);

bool Equal(int* left, const int* right) { return left == right; }

bool NotEqual(const int* left, int* right) { return left != right; }

bool IsNull(int* pointer) { return pointer == nullptr; }

bool NotNull(int* pointer) { return nullptr != pointer; }

bool CallbackIsNull(Callback callback) { return callback == nullptr; }

Callback EmptyCallback() { return nullptr; }

bool NullEqual() { return nullptr == nullptr; }

bool NullUnequal() { return (nullptr) != (nullptr); }

void DiscardNull() { (void)nullptr; }
