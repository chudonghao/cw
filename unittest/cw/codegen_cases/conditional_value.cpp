int ConditionalValue(bool flag, bool other, int left, int right) {
  return flag ? (other ? left : 7) : (other ? 11 : right);
}
