#pragma once

#include "../lv_conf.h"
#include "../lvgl/lvgl.h"

#ifndef TOKMAK_PLATFORM_PICO
#define TOKMAK_PLATFORM_PICO 0
#endif

#ifndef TOKMAK_PLATFORM_ESP_IDF
#define TOKMAK_PLATFORM_ESP_IDF 0
#endif

#if !TOKMAK_PLATFORM_PICO && !TOKMAK_PLATFORM_ESP_IDF && (defined(__APPLE__) || defined(__linux__))
#include "tokmak_sdl.h"
#endif

#include "epd_uc8253.h"
