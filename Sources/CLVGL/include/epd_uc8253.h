#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// The target platform is selected by the build system when needed
// (for example, with -DTOKMAK_PLATFORM_PICO=1).
#ifndef TOKMAK_PLATFORM_PICO
#define TOKMAK_PLATFORM_PICO 0
#endif

#ifndef TOKMAK_PLATFORM_ESP_IDF
#define TOKMAK_PLATFORM_ESP_IDF 0
#endif

// E-Paper dimensions
#define EPD_UC8253_WIDTH  240
#define EPD_UC8253_HEIGHT 416

// Display modes
typedef enum {
    EPD_MODE_FULL = 0,
    EPD_MODE_PARTIAL = 1
} epd_update_mode_t;

// API
void epd_uc8253_init(void);
void epd_uc8253_init_partial(void);
void epd_uc8253_sleep(void);
void epd_uc8253_clear(void);

// Update a specific region. Buffer should be 1 bit per pixel packed.
void epd_uc8253_update_region(const uint8_t *buffer, int x, int y, int w, int h, epd_update_mode_t mode);

#ifdef __cplusplus
}
#endif
