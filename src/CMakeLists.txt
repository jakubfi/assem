bison_target(parser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
flex_target(scanner scanner.l ${CMAKE_CURRENT_BINARY_DIR}/scanner.c)
add_flex_bison_dependency(scanner parser)

add_executable(assem
	assem.c elements.c eval.c keywords.c pprocess.c dict.c nodes.c image.c
	${BISON_parser_OUTPUTS}
	${FLEX_scanner_OUTPUTS}
)

install(TARGETS assem RUNTIME DESTINATION bin)

# vim: tabstop=4
