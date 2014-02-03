CMAKE_MINIMUM_REQUIRED(VERSION 2.8.4)
PROJECT(assem C)

set(ASSEM_VERSION 0.9.1)

find_package(BISON)
find_package(FLEX)

ADD_DEFINITIONS(-Wall -std=c99 -D_XOPEN_SOURCE=700 -O2 -DASSEM_VERSION="${ASSEM_VERSION}")

include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${CMAKE_BINARY_DIR}/build)

ADD_SUBDIRECTORY(src build)

# vim: tabstop=4
