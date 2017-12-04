cmake_minimum_required(VERSION 2.8.4)
project(assem C)

include(GNUInstallDirs)
include(appversion.cmake)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

add_definitions(-Wall -std=c99 -D_XOPEN_SOURCE=700 -O2 -DASSEM_VERSION="${APP_VERSION}")

include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${CMAKE_BINARY_DIR}/src)

add_subdirectory(src)

# vim: tabstop=4
