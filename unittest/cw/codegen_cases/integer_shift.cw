func SignedByte(left i8, count u64) i8 { left << count }
func UnsignedByte(left u8, count i64) u8 { left >> count }
func SignedByteRight(left i8, count i64) i8 { left >> count }
func SignedWord(left i16, count u8) i16 { left << count }
func UnsignedWord(left u16, count i8) u16 { left >> count }
func Signed32(left i32, count i64) i32 { left << count }
func Signed32Right(left i32, count u64) i32 { left >> count }
func Unsigned32(left u32, count i16) u32 { left << count }
func Signed64(left i64, count i8) i64 { left >> count }
func Unsigned64(left u64, count u32) u64 { left << count }
func Size(left isize, count i32) isize { left >> count }
func UnsignedSize(left usize, count u8) usize { left << count }
func FixedBySize(left u8, count usize) u8 { left << count }
func ShiftBeforeWidening(left u8) i32 { left << 1 }
func Literal32(count u64) i32 { 1 << count }
func FoldedWideCount() i32 { 1 << 4294967296 }
func FoldedNegativeCount() i32 { 8 >> -1 }
func FoldedNegativeLeft() i32 { -3 << 1 }
func FoldedSignBit() i32 { 1 << 31 }
func FoldedLostBits() i32 { (1 << 30) << 2 }
