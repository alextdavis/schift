cmake_minimum_required(VERSION 3.10)
project(kurtscheme)

file(GLOB SOURCES
        "Sources/Interpreter/*.swift"
        "Sources/Tokenize/*.swift"
        )

file(GLOB TESTS
        "Tests/**/*.swift")

add_custom_target(kurts_scheme ALL
        COMMAND /home/alex/swift-4.1.1-RELEASE-ubuntu16.04/usr/bin/swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES ${SOURCES} ${TESTS})
