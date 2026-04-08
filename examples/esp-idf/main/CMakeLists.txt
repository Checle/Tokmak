set(TOKMAK_SWIFT_EXECUTABLE "swift" CACHE STRING "Swift executable used to build the example Swift package")
set(TOKMAK_SWIFT_BUILD_MODE "release" CACHE STRING "SwiftPM build configuration for the example Swift package")
set(TOKMAK_SWIFT_SCRATCH_PATH "${CMAKE_BINARY_DIR}/swift-app-build" CACHE PATH "SwiftPM scratch path for the example Swift package")
set(TOKMAK_SWIFT_EXTRA_ARGS "" CACHE STRING "Extra arguments passed to swift build for the example Swift package")

set(TOKMAK_SWIFT_APP_PACKAGE_DIR "${CMAKE_CURRENT_LIST_DIR}/../swift-app")
set(TOKMAK_SWIFT_COMMON_ARGS
    --package-path "${TOKMAK_SWIFT_APP_PACKAGE_DIR}"
    --scratch-path "${TOKMAK_SWIFT_SCRATCH_PATH}"
    --product TokmakESPIDFApp
    -c "${TOKMAK_SWIFT_BUILD_MODE}"
    -Xcc -DTOKMAK_PLATFORM_ESP_IDF=1
    -Xswiftc -DTOKMAK_PLATFORM_ESP_IDF
)

set(TOKMAK_SWIFT_EXTRA_ARGS_LIST "")
if(TOKMAK_SWIFT_EXTRA_ARGS)
    separate_arguments(TOKMAK_SWIFT_EXTRA_ARGS_LIST NATIVE_COMMAND "${TOKMAK_SWIFT_EXTRA_ARGS}")
endif()

execute_process(
    COMMAND
        ${TOKMAK_SWIFT_EXECUTABLE} build
        ${TOKMAK_SWIFT_COMMON_ARGS}
        ${TOKMAK_SWIFT_EXTRA_ARGS_LIST}
        --show-bin-path
    WORKING_DIRECTORY "${TOKMAK_SWIFT_APP_PACKAGE_DIR}"
    OUTPUT_VARIABLE TOKMAK_SWIFT_BIN_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(TOKMAK_SWIFT_LIBRARY "${TOKMAK_SWIFT_BIN_PATH}/libTokmakESPIDFApp.a")

add_custom_command(
    OUTPUT "${TOKMAK_SWIFT_LIBRARY}"
    COMMAND
        ${TOKMAK_SWIFT_EXECUTABLE} build
        ${TOKMAK_SWIFT_COMMON_ARGS}
        ${TOKMAK_SWIFT_EXTRA_ARGS_LIST}
    WORKING_DIRECTORY "${TOKMAK_SWIFT_APP_PACKAGE_DIR}"
    COMMENT "Building Tokmak ESP-IDF Swift package"
    VERBATIM
)

add_custom_target(tokmak_swift_app_build DEPENDS "${TOKMAK_SWIFT_LIBRARY}")

add_library(tokmak_swift_app STATIC IMPORTED GLOBAL)
set_target_properties(tokmak_swift_app PROPERTIES IMPORTED_LOCATION "${TOKMAK_SWIFT_LIBRARY}")
add_dependencies(tokmak_swift_app tokmak_swift_app_build)

idf_component_register(
    SRCS
        "app_main.c"
        "hardware_bridge.c"
    INCLUDE_DIRS
        "."
    REQUIRES
        driver
        esp_timer
)

target_link_libraries(${COMPONENT_LIB} PRIVATE tokmak_swift_app)
