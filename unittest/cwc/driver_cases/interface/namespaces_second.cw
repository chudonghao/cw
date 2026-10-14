namespace alpha {
  export func Other(value *::outer::inner::Item) *::outer::inner::Item { value }
}
export func Root(value *Item) *Item { value }
namespace vanished {
  namespace empty { func Hidden() {} }
}
