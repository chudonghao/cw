namespace api {
// These operations are defined in another translation unit.
struct Box {
  int value;
  explicit Box(int value);
  Box(const Box& source);
  Box(Box&& source);
  ~Box();
  void operator=(const Box& source);
  void operator=(Box&& source);
};
int Read(const Box& value);
Box Make();
void Flush();
}  // namespace api

auto global = api::Make();
int Use() {
  api::Box first(1);
  auto second = first;
  first = second;
  second = static_cast<api::Box&&>(first);
  auto third = static_cast<api::Box&&>(second);
  api::Flush();
  return api::Read(third);
}
