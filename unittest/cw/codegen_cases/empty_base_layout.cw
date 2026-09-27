trivial struct Empty {}
trivial struct Member { empty Empty; }
trivial struct Distinct : Empty { member Member; value u8; }
struct Anchor {}
ctor Anchor() {}
dtor Anchor() {}
struct Aligned : Anchor { zero [0] i32; }
ctor Aligned() { this.Anchor := Anchor(); this.zero := [0] i32 {}; }
dtor Aligned() {}
struct Child : Aligned { value u8; }
ctor Child() { this.Aligned := Aligned(); this.value := 7; }
dtor Child() {}

func Base(value &mut Distinct) *Empty { &value.Empty }
func Nested(value &mut Distinct) *Empty { &value.member.empty }
func Last(value &mut Distinct) *u8 { &value.value }
func Make() Child { Child() }
