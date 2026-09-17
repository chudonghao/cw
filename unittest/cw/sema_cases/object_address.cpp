struct Addressed {
  int value;
};

void ObjectAddress(Addressed object, const Addressed& readonly, int* pointer, bool condition, int first,
                   int second) {
  &object;
  &readonly;
  &object.value;
  &*pointer;
  &(condition ? first : second);
  &(first = second);
}
