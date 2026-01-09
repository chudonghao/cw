add_executable(cwlang main.cpp)

target_link_libraries(cwlang cw Boost::boost Boost::filesystem Boost::program_options)