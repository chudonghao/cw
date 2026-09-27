func SelectMutable(flag bool, left &mut bool, right &mut bool) &mut bool {
  flag ? left : right
}

func ReadMutable(flag bool, left bool, right bool) bool {
  SelectMutable(flag, left, right)
}

func SelectCopy(flag bool, left &copy bool, right &copy bool) &copy bool {
  flag ? left : right
}

func ReadCopy(flag bool, left bool, right bool) bool {
  SelectCopy(flag, left, right)
}

func SelectMove(flag bool, left &move bool, right &move bool) &move bool {
  flag ? move left : move right
}

func ReadMove(flag bool, left bool, right bool) bool {
  SelectMove(flag, move left, move right)
}
