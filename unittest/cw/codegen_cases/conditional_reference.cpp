bool& SelectMutable(bool flag, bool& left, bool& right) { return flag ? left : right; }

bool ReadMutable(bool flag, bool left, bool right) { return SelectMutable(flag, left, right); }

const bool& SelectCopy(bool flag, const bool& left, const bool& right) { return flag ? left : right; }

bool ReadCopy(bool flag, bool left, bool right) { return SelectCopy(flag, left, right); }

bool&& SelectMove(bool flag, bool&& left, bool&& right) {
  return flag ? static_cast<bool&&>(left) : static_cast<bool&&>(right);
}

bool ReadMove(bool flag, bool left, bool right) {
  return SelectMove(flag, static_cast<bool&&>(left), static_cast<bool&&>(right));
}
