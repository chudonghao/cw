trivial struct Empty {}
trivial struct Aligned { values [0] i64; }

func Make(counter &mut i32) var result Empty {
  counter = counter + 1;
  result := Empty();
}

func Take(value Empty, number i8) i8 { number }
func Use(counter &mut i32, number i8) i8 { Take(Make(counter), number) }
func Identity(value Aligned) Aligned { value }
func Form(value &copy Aligned) { var result := Identity(value); }

func Mixed(empty Empty, flag bool, value [3] i64, number i8) [3] i64 { value }
func Combine(value &copy [3] i64, flag bool, number i8) [3] i64 {
  Mixed(Empty(), flag, value, number)
}
