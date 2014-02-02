CMAKE_MINIMUM_REQUIRED(VERSION 2.8.4)
PROJECT(assem C)

set(ASSEM_VERSION 0.9.1)

find_package(BISON)
find_package(FLEX)

ADD_DEFINITIONS(-Wall -std=c99 -D_XOPEN_SOURCE=700 -O2 -DASSEM_VERSION="${ASSEM_VERSION}")

include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_BINARY_DIR})

BISON_TARGET(parser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
FLEX_TARGET(scanner scanner.l ${CMAKE_CURRENT_BINARY_DIR}/scanner.c)
ADD_FLEX_BISON_DEPENDENCY(scanner parser)

ADD_EXECUTABLE(assem assem.c elements.c eval.c keywords.c pprocess.c dict.c nodes.c image.c
${BISON_parser_OUTPUTS}
${FLEX_scanner_OUTPUTS}
)

install(TARGETS assem RUNTIME DESTINATION bin)

# vim: tabstop=4
