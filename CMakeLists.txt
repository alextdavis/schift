cmake_minimum_required(VERSION 3.10)
project(schift)

file(GLOB SOURCES
        "Sources/*/*.swift"
        )

file(GLOB TESTS
        "Tests/*/*.swift")

add_custom_target(schift ALL
        COMMAND /usr/bin/swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES ${SOURCES} ${TESTS})
