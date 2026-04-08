#pragma once

#include "../lv_conf.h"
#include "../lvgl/lvgl.h"

#ifdef __cplusplus
extern "C" {
#endif

// A tiny custom SDL2 bridge for Tokmak
// Replaces the heavy and problematic lv_drivers module

void tokmak_sdl_init(int width, int height);

void tokmak_sdl_display_flush(lv_disp_drv_t * disp_drv, const lv_area_t * area, lv_color_t * color_p);

void tokmak_sdl_mouse_read(lv_indev_drv_t * indev_drv, lv_indev_data_t * data);

void tokmak_sdl_loop(void);

#ifdef __cplusplus
}
#endif
