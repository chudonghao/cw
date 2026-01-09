cmake_minimum_required(VERSION 3.21)
project(cw VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(MSVC)
  add_compile_options(/utf-8)
  add_compile_options($<$<AND:$<BOOL:${MSVC}>,$<CONFIG:RelWithDebInfo>>:/Od>)
endif()

set(Boost_USE_STATIC_LIBS ON)
find_package(Boost REQUIRED COMPONENTS filesystem program_options)

add_subdirectory(src)

if(CW_BUILD_TESTS)
  add_subdirectory(test)
endif()
