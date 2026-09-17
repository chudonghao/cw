trivial struct Addressed {
  value i32;
}

func ObjectAddress(object Addressed, readonly copy Addressed, pointer *i32, condition bool, first i32,
                   second i32) {
  &object;
  &readonly;
  &object.value;
  &*pointer;
  &(condition ? first : second);
  &(first = second);
}
