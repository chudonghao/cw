declare noundef ptr @"cw:api::Owner:dtor():complete"(ptr noundef returned)

declare noundef ptr @"cw:api::Owner:dtor():base"(ptr noundef returned)

declare noundef i32 @"cw:api::Scalar:func(isize)i32"(i64 noundef)

declare noundef i32 @"cw:api::Scalar:func(i64)i32"(i64 noundef)

declare noundef i32 @"cw:api::Reference:func(&copy i32)i32"(ptr noundef nonnull align 4 dereferenceable(4))

declare noundef i32 @"cw:api::Reference:func(&mut i32)i32"(ptr noundef nonnull align 4 dereferenceable(4))

declare noundef i32 @"cw:api::Reference:func(&move i32)i32"(ptr noundef nonnull align 4 dereferenceable(4))

declare noundef i32 @"cw:api::Qualified:func(*const *i32)i32"(ptr noundef)

declare noundef i32 @"cw:api::Qualified:func(**const i32)i32"(ptr noundef)

declare noundef i32 @"cw:api::Array:func(&copy [4]i32)i32"(ptr noundef nonnull align 4 dereferenceable(16))

declare noundef i32 @"cw:api::Callback:func(*func(i32)i32)i32"(ptr noundef)

declare noundef i32 @"cw:api::Callback:func(virtual *func(&copy api::Owner)i32)i32"([2 x i64] noundef)

declare noundef i32 @"cw:api::main:func(i32)i32"(i32 noundef)

declare noundef i32 @"cw:api::\E8\AF\BB\E5\8F\96:func(i32)i32"(i32 noundef)

declare noundef i32 @main()
