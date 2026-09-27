%struct.Holder = type { i8 }
%struct.Token = type { i8 }

define noundef ptr @Token.ctor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Token.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define noundef ptr @Holder.ctor(ptr noundef returned %this, ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  ret ptr %this
}

define noundef ptr @Holder.dtor(ptr noundef returned %this) {
entry:
  ret ptr %this
}

define void @Make(ptr sret(%struct.Holder) align 1 %.result, ptr noundef nonnull align 1 dereferenceable(1) %value) {
entry:
  %value.addr = alloca ptr, align 8
  store ptr %value, ptr %value.addr, align 8
  %0 = load ptr, ptr %value.addr, align 8
  %call = call noundef ptr @Holder.ctor(ptr noundef returned %.result, ptr noundef nonnull align 1 dereferenceable(1) %0)
  ret void
}

define void @Boundaries() {
entry:
  %first = alloca %struct.Holder, align 1
  %second = alloca %struct.Holder, align 1
  %temporary = alloca %struct.Token, align 1
  %temporary3 = alloca %struct.Token, align 1
  %block = alloca %struct.Holder, align 1
  %inner = alloca %struct.Token, align 1
  %temporary7 = alloca %struct.Token, align 1
  %call = call noundef ptr @Token.ctor(ptr noundef returned %temporary)
  %call1 = call noundef ptr @Holder.ctor(ptr noundef returned %first, ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %call2 = call noundef ptr @Token.dtor(ptr noundef returned %temporary)
  %call4 = call noundef ptr @Token.ctor(ptr noundef returned %temporary3)
  call void @Make(ptr sret(%struct.Holder) align 1 %second, ptr noundef nonnull align 1 dereferenceable(1) %temporary3)
  %call5 = call noundef ptr @Token.dtor(ptr noundef returned %temporary3)
  %call6 = call noundef ptr @Token.ctor(ptr noundef returned %inner)
  %call8 = call noundef ptr @Token.ctor(ptr noundef returned %temporary7)
  %call9 = call noundef ptr @Holder.ctor(ptr noundef returned %block, ptr noundef nonnull align 1 dereferenceable(1) %temporary7)
  %call10 = call noundef ptr @Token.dtor(ptr noundef returned %temporary7)
  %call11 = call noundef ptr @Token.dtor(ptr noundef returned %inner)
  %call12 = call noundef ptr @Holder.dtor(ptr noundef returned %block)
  %call13 = call noundef ptr @Holder.dtor(ptr noundef returned %second)
  %call14 = call noundef ptr @Holder.dtor(ptr noundef returned %first)
  ret void
}

define void @Returning(ptr sret(%struct.Holder) align 1 %.result) {
entry:
  %local = alloca %struct.Token, align 1
  %temporary = alloca %struct.Token, align 1
  %call = call noundef ptr @Token.ctor(ptr noundef returned %local)
  %call1 = call noundef ptr @Token.ctor(ptr noundef returned %temporary)
  %call2 = call noundef ptr @Holder.ctor(ptr noundef returned %.result, ptr noundef nonnull align 1 dereferenceable(1) %temporary)
  %call3 = call noundef ptr @Token.dtor(ptr noundef returned %temporary)
  %call4 = call noundef ptr @Token.dtor(ptr noundef returned %local)
  ret void
}
