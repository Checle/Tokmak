#pragma once

#include "../lv_conf.h"
#include "../lvgl/lvgl.h"

#ifndef TOKMAK_PLATFORM_PICO
#define TOKMAK_PLATFORM_PICO 0
#endif

#ifndef TOKMAK_PLATFORM_ESP_IDF
#define TOKMAK_PLATFORM_ESP_IDF 0
#endif

#include "tokmak_sdl.h"

#include "epd_uc8253.h"

static inline const lv_font_t *tokmak_lv_font_montserrat(int size) {
    if(size < 9) return &lv_font_montserrat_8;
    if(size < 11) return &lv_font_montserrat_10;
    if(size < 13) return &lv_font_montserrat_12;
    if(size < 15) return &lv_font_montserrat_14;
    if(size < 17) return &lv_font_montserrat_16;
    if(size < 19) return &lv_font_montserrat_18;
    if(size < 21) return &lv_font_montserrat_20;
    if(size < 23) return &lv_font_montserrat_22;
    if(size < 25) return &lv_font_montserrat_24;
    if(size < 27) return &lv_font_montserrat_26;
    if(size < 29) return &lv_font_montserrat_28;
    if(size < 31) return &lv_font_montserrat_30;
    if(size < 33) return &lv_font_montserrat_32;
    if(size < 35) return &lv_font_montserrat_34;
    if(size < 37) return &lv_font_montserrat_36;
    if(size < 39) return &lv_font_montserrat_38;
    if(size < 41) return &lv_font_montserrat_40;
    if(size < 43) return &lv_font_montserrat_42;
    if(size < 45) return &lv_font_montserrat_44;
    if(size < 47) return &lv_font_montserrat_46;
    return &lv_font_montserrat_48;
}
