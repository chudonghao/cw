func Plain() *const [3] u8 { &"abc" }

func Joined() *const [3] u8 { &"\x61" "bc" }

func Embedded() *const [3] u8 { &"a\0b" }

func EmbeddedOther() *const [3] u8 { &"a\0c" }

func ExplicitEnd() *const [4] u8 { &"abc\0" }

func Bytes() *const [2] u8 { &"\xFF\xFE" }

func Text() *const [3] u8 { &"中" }

func SplitEscape() *const [2] u8 { &"\x4" "1" }

func Empty() *const [0] u8 { &"" }

func Zero() *const [1] u8 { &"\0" }
