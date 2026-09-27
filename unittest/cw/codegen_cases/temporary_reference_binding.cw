func ReadInteger(value &copy i32) i32 {
  value
}

func IntegerTemporary() i32 {
  ReadInteger(53)
}

func ReadBoolean(value &copy bool) bool {
  value
}

func ConditionalBooleanTemporary(flag bool) bool {
  ReadBoolean(flag ? false : true)
}
