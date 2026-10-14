export trivial struct Item {}
namespace alpha {
  export trivial struct Item {}
  namespace hidden { func Discard() {} }
  export func Read(value &copy ::Item) {}
}
namespace outer::inner {
  export trivial struct Item {}
  export func Read(value &copy Item) {}
}
namespace alpha {
  export func Identity(value *Item) *Item { value }
}
