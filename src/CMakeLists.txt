BISON_TARGET(parser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c)
FLEX_TARGET(scanner scanner.l ${CMAKE_CURRENT_BINARY_DIR}/scanner.c)
ADD_FLEX_BISON_DEPENDENCY(scanner parser)

ADD_EXECUTABLE(assem assem.c elements.c eval.c keywords.c pprocess.c dict.c nodes.c image.c
${BISON_parser_OUTPUTS}
${FLEX_scanner_OUTPUTS}
)

install(TARGETS assem RUNTIME DESTINATION bin)

# vim: tabstop=4
