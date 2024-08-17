cmake_minimum_required(VERSION 3.20)
project(freecad-launcher LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

add_executable(FreeCAD FreeCAD.cpp)
target_link_libraries(FreeCAD)
