cmake_minimum_required(VERSION 3.0)
project(assem
	DESCRIPTION "MERA-400 assembler with classic syntax"
	LANGUAGES C
)

include(GNUInstallDirs)
include(appversion.cmake)

add_compile_options(-Wall)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

bison_target(parser src/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
flex_target(scanner src/scanner.l ${CMAKE_CURRENT_BINARY_DIR}/scanner.c)
add_flex_bison_dependency(scanner parser)

add_executable(assem
	src/assem.c
	src/elements.c
   	src/eval.c
   	src/keywords.c
   	src/pprocess.c
   	src/dict.c
   	src/nodes.c
   	src/image.c
	src/dict.h
	src/elements.h
	src/errors.h
	src/eval.h
	src/image.h
	src/keywords.h
	src/nodes.h
	src/pprocess.h
	${BISON_parser_OUTPUTS}
	${FLEX_scanner_OUTPUTS}
)

target_include_directories(assem PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_include_directories(assem PRIVATE ${CMAKE_BINARY_DIR})
set_property(TARGET assem PROPERTY C_STANDARD 99)
target_compile_definitions(assem PRIVATE ASSEM_VERSION="${APP_VERSION}")
target_compile_definitions(assem PRIVATE _XOPEN_SOURCE=700)

install(TARGETS assem
	RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# vim: tabstop=4
