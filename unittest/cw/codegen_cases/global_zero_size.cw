var trace i64 := 0;
func Mark(value i32) { trace = trace * 10 + value; }
struct Empty {}
ctor Empty() { Mark(1); }
ctor Empty(other &copy Empty) { Mark(2); }
dtor Empty() { Mark(-1); }

var empty := Empty();
var pair := [2] Empty { Empty(), Empty() };
var none := [0] Empty {};
var nested := [2][0] Empty { [0] Empty {}, [0] Empty {} };
func Source() &copy [2][0] Empty { Mark(3); nested }
var copied := Source();
