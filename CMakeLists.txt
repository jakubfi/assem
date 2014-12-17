cmake_minimum_required(VERSION 2.8.4)
project(assem C)

set(ASSEM_VERSION_MAJOR 0)
set(ASSEM_VERSION_MINOR 9)
set(ASSEM_VERSION_PATCH 1)
set(ASSEM_VERSION ${ASSEM_VERSION_MAJOR}.${ASSEM_VERSION_MINOR}.${ASSEM_VERSION_PATCH})

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

add_definitions(-Wall -std=c99 -D_XOPEN_SOURCE=700 -O2 -DASSEM_VERSION="${ASSEM_VERSION}")

include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${CMAKE_BINARY_DIR}/src)

add_subdirectory(src)

# vim: tabstop=4
