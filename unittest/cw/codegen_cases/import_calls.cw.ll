%"struct.api::Box" = type { i32 }

@__dso_handle = external hidden global i8
@"cw:global:var" = global %"struct.api::Box" zeroinitializer, align 4
@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @"cw:global_init", ptr null }]

; Function Attrs: nounwind
declare i32 @__cxa_atexit(ptr, ptr, ptr) #0

declare noundef ptr @"cw:api::Box:ctor(i32):complete"(ptr noundef returned, i32 noundef)

declare noundef ptr @"cw:api::Box:ctor(i32):base"(ptr noundef returned, i32 noundef)

declare noundef ptr @"cw:api::Box:ctor(&copy api::Box):complete"(ptr noundef returned, ptr noundef nonnull align 4 dereferenceable(4))

declare noundef ptr @"cw:api::Box:ctor(&copy api::Box):base"(ptr noundef returned, ptr noundef nonnull align 4 dereferenceable(4))

declare noundef ptr @"cw:api::Box:ctor(&move api::Box):complete"(ptr noundef returned, ptr noundef nonnull align 4 dereferenceable(4))

declare noundef ptr @"cw:api::Box:ctor(&move api::Box):base"(ptr noundef returned, ptr noundef nonnull align 4 dereferenceable(4))

declare noundef ptr @"cw:api::Box:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:api::Box:dtor():base"(ptr noundef returned)

declare void @"cw:api::operator=:func(&mut api::Box,&copy api::Box)void"(ptr noundef nonnull align 4 dereferenceable(4), ptr noundef nonnull align 4 dereferenceable(4))

declare void @"cw:api::operator=:func(&mut api::Box,&move api::Box)void"(ptr noundef nonnull align 4 dereferenceable(4), ptr noundef nonnull align 4 dereferenceable(4))

declare noundef i32 @"cw:api::Read:func(&copy api::Box)i32"(ptr noundef nonnull align 4 dereferenceable(4))

declare void @"cw:api::Make:func()api::Box"(ptr sret(%"struct.api::Box") align 4)

declare void @"cw:api::Flush:func()void"()

define noundef i32 @"cw:Use:func()i32"() {
entry:
  %.result = alloca i32, align 4
  %first = alloca %"struct.api::Box", align 4
  %second = alloca %"struct.api::Box", align 4
  %third = alloca %"struct.api::Box", align 4
  %call = call noundef ptr @"cw:api::Box:ctor(i32):complete"(ptr noundef returned %first, i32 noundef 1)
  %call1 = call noundef ptr @"cw:api::Box:ctor(&copy api::Box):complete"(ptr noundef returned %second, ptr noundef nonnull align 4 dereferenceable(4) %first)
  call void @"cw:api::operator=:func(&mut api::Box,&copy api::Box)void"(ptr noundef nonnull align 4 dereferenceable(4) %first, ptr noundef nonnull align 4 dereferenceable(4) %second)
  call void @"cw:api::operator=:func(&mut api::Box,&move api::Box)void"(ptr noundef nonnull align 4 dereferenceable(4) %second, ptr noundef nonnull align 4 dereferenceable(4) %first)
  %call2 = call noundef ptr @"cw:api::Box:ctor(&move api::Box):complete"(ptr noundef returned %third, ptr noundef nonnull align 4 dereferenceable(4) %second)
  call void @"cw:api::Flush:func()void"()
  %call3 = call noundef i32 @"cw:api::Read:func(&copy api::Box)i32"(ptr noundef nonnull align 4 dereferenceable(4) %third)
  store i32 %call3, ptr %.result, align 4
  %call4 = call noundef ptr @"cw:api::Box:dtor():complete"(ptr noundef returned %third)
  %call5 = call noundef ptr @"cw:api::Box:dtor():complete"(ptr noundef returned %second)
  %call6 = call noundef ptr @"cw:api::Box:dtor():complete"(ptr noundef returned %first)
  %0 = load i32, ptr %.result, align 4
  ret i32 %0
}

define internal void @"cw:global_var_init"() {
entry:
  call void @"cw:api::Make:func()api::Box"(ptr sret(%"struct.api::Box") align 4 @"cw:global:var")
  %0 = call i32 @__cxa_atexit(ptr @"cw:api::Box:dtor():complete", ptr @"cw:global:var", ptr @__dso_handle) #0
  ret void
}

define internal void @"cw:global_init"() {
entry:
  call void @"cw:global_var_init"()
  ret void
}

attributes #0 = { nounwind }
