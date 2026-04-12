if(TARGET CLVGL AND TARGET TokmakUI)
    return()
endif()

set(TOKMAK_ROOT "${CMAKE_CURRENT_LIST_DIR}")

file(GLOB_RECURSE TOKMAKUI_SWIFT_SOURCES CONFIGURE_DEPENDS "${TOKMAK_ROOT}/Sources/TokmakUI/*.swift")
file(GLOB_RECURSE LVGL_C_SOURCES CONFIGURE_DEPENDS "${TOKMAK_ROOT}/Sources/CLVGL/lvgl/src/*.c")

add_library(CLVGL STATIC
    ${LVGL_C_SOURCES}
    "${TOKMAK_ROOT}/Sources/CLVGL/epd_uc8253.c"
    "${TOKMAK_ROOT}/Sources/CLVGL/tokmak_sdl.c"
)

target_compile_definitions(CLVGL
    PRIVATE
        LV_LVGL_H_INCLUDE_SIMPLE
)

if(TOKMAK_PLATFORM_PICO)
    target_compile_definitions(CLVGL PRIVATE TOKMAK_PLATFORM_PICO=1)
endif()

target_include_directories(CLVGL
    PUBLIC
        "${TOKMAK_ROOT}/Sources/CLVGL/include"
        "${TOKMAK_ROOT}/Sources/CLVGL"
        "${TOKMAK_ROOT}/Sources/CLVGL/lvgl"
)

add_library(TokmakUI STATIC ${TOKMAKUI_SWIFT_SOURCES})
target_link_libraries(TokmakUI PUBLIC CLVGL)
