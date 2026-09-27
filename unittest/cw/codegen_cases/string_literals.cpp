// C++ literals contain char elements and a trailing zero; CW literals contain only their u8 content bytes.
// These functions expose the complete arrays, including C++'s extra element.
auto Plain() -> const char (*)[4] { return &"abc"; }

auto Joined() -> const char (*)[4] {
  return &"\x61" "bc";
}

auto Embedded() -> const char (*)[4] { return &"a\0b"; }

auto EmbeddedOther() -> const char (*)[4] { return &"a\0c"; }

auto ExplicitEnd() -> const char (*)[5] { return &"abc\0"; }

auto Bytes() -> const char (*)[3] { return &"\xFF\xFE"; }

auto Text() -> const char (*)[4] { return &"中"; }

auto SplitEscape() -> const char (*)[3] {
  return &"\x4" "1";
}

auto Empty() -> const char (*)[1] { return &""; }

auto Zero() -> const char (*)[2] { return &"\0"; }
