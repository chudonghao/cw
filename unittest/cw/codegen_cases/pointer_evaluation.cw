func Set(target &mut *i32, next *i32) *i32 {
  target = next;
  target
}

func CompareBeforeChange(target &mut *i32, next *i32) bool {
  target == Set(target, next)
}

func Choose(flag bool, pointer *i32) *const i32 {
  flag ? pointer : null
}

func Select(flag bool, left &mut *i32, right &mut *i32) &mut *i32 {
  flag ? left : right
}

func WriteSelected(flag bool, left &mut *i32, right &mut *i32, value *i32) {
  Select(flag, left, right) = value;
}

func Locate(pointer *i32, count &mut i32) *i32 {
  count = count + 1;
  pointer
}

func Next(value &mut i32) i32 {
  value = value + 1;
  value
}

func AssignOnce(pointer *i32, state &mut i32) {
  *Locate(pointer, state) = Next(state);
}
