// C++ uses its own mangling. long and long long remain distinct at equal width;
// const/lvalue/rvalue references correspond to CW's copy/mut/move modes.
namespace api {
struct Owner {
  virtual int Read() const;
  ~Owner();
};
int Scalar(long value);
int Scalar(long long value);
int Reference(const int& value);
int Reference(int& value);
int Reference(int&& value);
int Qualified(int* const* value);
int Qualified(const int** value);
int Array(const int (&value)[2 + 2]);
int Callback(int (*value)(int));
// A member pointer is the C++ counterpart of CW's unbound virtual interface pointer.
int Callback(int (Owner::*value)() const);
int main(int value);
int 读取(int value);
}
int main();
// Taking addresses keeps the external declarations in the Clang reference.
auto ScalarSize = static_cast<int (*)(long)>(&api::Scalar);
auto ScalarFixed = static_cast<int (*)(long long)>(&api::Scalar);
auto Copy = static_cast<int (*)(const int&)>(&api::Reference);
auto Mut = static_cast<int (*)(int&)>(&api::Reference);
auto Move = static_cast<int (*)(int&&)>(&api::Reference);
auto ConstPointer = static_cast<int (*)(int* const*)>(&api::Qualified);
auto ConstPointee = static_cast<int (*)(const int**)>(&api::Qualified);
auto Array = &api::Array;
auto Direct = static_cast<int (*)(int (*)(int))>(&api::Callback);
auto Virtual = static_cast<int (*)(int (api::Owner::*)() const)>(&api::Callback);
auto NestedMain = &api::main;
auto Unicode = &api::读取;
void Destroy(api::Owner* value) { value->~Owner(); }
