trivial struct Tag { tag i32; }
trivial struct Product { value i32; }
// Product follows Tag in Special, at offset four.
trivial struct Special : Tag, Product {}

import struct Plain {
  virtual {
    func Id(this &copy Plain) i32;
    func Item(this &copy Plain) *Product;
  }
}
import ctor Plain();
import dtor Plain();
import struct Maker {
  virtual {
    func Make(this &copy Maker) *Product;
    func Get(this &copy Maker) &copy Product;
  }
}
import ctor Maker();
import dtor Maker();

// Through Maker, the thunks adjust the receiver to Factory and the result to Product. Item
// overrides the primary base Plain but needs a result adjustment, so it takes a new slot and
// Plain's slot only adjusts the result.
struct Factory : Plain, Maker {
  virtual {
    override func Make(this &copy Factory) *Special;
    override func Get(this &copy Factory) &copy Special;
    override func Item(this &copy Factory) *Special;
  }
  target *Special;
}
func Make(this &copy Factory) *Special { this.target }
func Get(this &copy Factory) &copy Special { *this.target }
func Item(this &copy Factory) *Special { this.target }
ctor Factory(target *Special) {
  this.Plain := Plain();
  this.Maker := Maker();
  this.target := target;
}
dtor Factory() {}

func MakeThrough(maker &copy Maker) *Product { maker.Make() }
func GetThrough(maker &copy Maker) &copy Product { maker.Get() }
func MakeDirect(factory &copy Factory) *Special { factory.Make() }
