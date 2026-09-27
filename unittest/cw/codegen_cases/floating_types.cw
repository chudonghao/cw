func Single(value f32) f32 {
  value
}

func Double(value f64) f64 {
  value
}

func Read(value &copy f64) f64 {
  value
}

func Locate(value &mut f32) &mut f32 {
  value
}

func Assign(target &mut f32, source f64) {
  Locate(target) = source;
}

func Forward(value f32) f64 {
  value.Double()
}

func Temporary() f64 {
  Read(0.5)
}

func ReadMove(value &move f32) f32 {
  value
}

func MoveLocal() f32 {
  var value f32 := 2.5f;
  ReadMove(move value)
}
