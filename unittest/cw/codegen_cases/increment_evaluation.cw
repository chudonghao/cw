trivial struct Item { value i32; }

func Locate(value &mut i32, counter &mut i32) &mut i32 { ++counter; value }
func Prefix(value &mut i32, counter &mut i32) &mut i32 { ++Locate(value, counter) }
func Postfix(value &mut i32, counter &mut i32) i32 { Locate(value, counter)-- }
func Pair(value &mut i32) i32 { value++ + value }
func Mixed(value &mut i32) i32 { ++value + value++ }
func SelfAssignment(value &mut i32) i32 { value = value++ }
func Element(data &mut [2] i32, index &mut usize) i32 { data[index++]++ }
func Conditional(first &mut i32, second &mut i32, choose bool) i32 { (choose ? first : second)++ }
func ShortCircuit(value &mut i32, choose bool) bool { choose && value++ == 1 }
func Address(value &mut i32) *i32 { &(--value) }
func Chain(value &mut i32) i32 { ++(++value) }
func Assign(value &mut i32) { (++value) = 5; }
func Compound(value &mut i32) i32 { ++value += value++ }
func Field(item &mut Item) i32 { item.value++ }
func Dereference(pointer *i32) i32 { (*pointer)-- }
func Discard(value &mut i32) { ++value; value++; --value; value--; }
