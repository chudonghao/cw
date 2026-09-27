int ReadInteger(const int& value) { return value; }
int IntegerTemporary() { return ReadInteger(53); }

bool ReadBoolean(const bool& value) { return value; }
bool ConditionalBooleanTemporary(bool flag) { return ReadBoolean(flag ? false : true); }
