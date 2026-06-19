# pascal — the Pascal front end for the PSCAL VM.
#
# Parses Pascal source into the shared PSCAL AST, which the shared bytecode
# compiler lowers and the PSCAL VM runs. Pulls pscal-core in via FetchContent,
# so building this repo on its own fetches and builds the shared core
# automatically.
cmake_minimum_required(VERSION 3.18)
project(pascal C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
add_compile_options(-Wall)
if(UNIX AND NOT APPLE)
    add_compile_definitions(_GNU_SOURCE _POSIX_C_SOURCE=200809L)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
    add_compile_options(-Wno-nullability-completeness)
endif()

find_package(Threads REQUIRED)

include(FetchContent)
FetchContent_Declare(
    pscal_core
    GIT_REPOSITORY https://github.com/emkey1/pscal-core.git
    GIT_TAG main
)
FetchContent_MakeAvailable(pscal_core)

include_directories(
    ${pscal_core_SOURCE_DIR}/src
    ${pscal_core_SOURCE_DIR}/src/core
    ${pscal_core_SOURCE_DIR}/src/third_party/yyjson
    ${CMAKE_BINARY_DIR}/generated
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

add_compile_definitions(
    PROGRAM_VERSION="0.0.0"
    PSCAL_GIT_TAG="untagged"
    ENABLE_EXT_BUILTIN_MATH ENABLE_EXT_BUILTIN_STRINGS ENABLE_EXT_BUILTIN_SYSTEM
    ENABLE_EXT_BUILTIN_USER ENABLE_EXT_BUILTIN_YYJSON ENABLE_EXT_BUILTIN_3D
    ENABLE_EXT_BUILTIN_GRAPHICS
)

set(PASCAL_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Pascal/main.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Pascal/parser.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Pascal/semantic.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Pascal/opt.c
)

add_executable(pascal ${PASCAL_SOURCES})
target_link_libraries(pascal PRIVATE pscal_core_static Threads::Threads m)

# ---- Install ----------------------------------------------------------------
# `cmake --install build` puts `pascal` on PATH and ships the examples and the
# language docs beside it. The FetchContent dep (pscal-core) declares no install
# rules of its own, so only Pascal's targets are installed here.
include(GNUInstallDirs)
install(TARGETS pascal RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/examples/
        DESTINATION ${CMAKE_INSTALL_DATADIR}/pascal/examples)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/docs/
        DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/README.md
        DESTINATION ${CMAKE_INSTALL_DOCDIR})

# ---- Test -------------------------------------------------------------------
# `ctest` runs the .pas corpus and the compiler regression suite in tests/
# against the binary just built. The runner picks up PASCAL_BIN from the
# environment, which CTest points at the freshly built executable.
enable_testing()
add_test(NAME pascal_tests COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/tests/run.sh)
set_tests_properties(pascal_tests PROPERTIES
    ENVIRONMENT "PASCAL_BIN=$<TARGET_FILE:pascal>")
