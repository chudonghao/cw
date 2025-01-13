include_directories(${CMAKE_CURRENT_SOURCE_DIR})

set(Boost_USE_STATIC_LIBS ON)
find_package(Boost REQUIRED COMPONENTS filesystem)
link_directories(${Boost_LIBRARY_DIRS})

add_subdirectory(cw)
add_subdirectory(cwlang)