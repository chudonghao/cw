trivial struct FloatBase { x f64; }
trivial struct Floats : FloatBase { y f64; }
trivial struct BigBase { values [3] i64; }
trivial struct Big : BigBase { flag bool; }

func FloatIdentity(value Floats) Floats { value }
func FloatCall(value &copy Floats) Floats { FloatIdentity(value) }
func MakeBigBase() BigBase { BigBase() }

func BigCall() Big {
  var value Big := {
    value.BigBase := MakeBigBase();
    value.flag := true;
  }
  value
}

func Indirect(callback *func (Big) Big, value &copy Big) Big { callback(value) }
