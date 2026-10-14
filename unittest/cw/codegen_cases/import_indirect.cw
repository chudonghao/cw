import struct Base {
  virtual {
    func Read(this &copy Base) i32;
    abstract func Abstract(this &copy Base) i32;
  }
}
import dtor Base();
import func Unused();
func Dispatch(value &copy Base) i32 { value.Read() + value.Abstract() }
func Slot() virtual *func(&copy Base) i32 { &Read }
