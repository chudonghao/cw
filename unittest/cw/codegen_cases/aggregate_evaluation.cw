trivial struct Pair { first i64; second i64; }
trivial struct Triple { first i64; second i64; third i64; }

func ChangeSmall(value &mut Pair) i32 { value.first = 99; 0 }
func TakeSmall(value Pair, ignored i32) i64 { value.second = 7; value.first }
func Small(value &mut Pair) i64 { TakeSmall(value, ChangeSmall(value)) }

func ChangeLarge(value &mut Triple) i32 { value.first = 99; 0 }
func TakeLarge(value Triple, ignored i32) i64 { value.second = 7; value.first }
func Large(value &mut Triple) i64 { TakeLarge(value, ChangeLarge(value)) }
