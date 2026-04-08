#pragma once

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Define the platform we are targeting. 
// In a real build system, this would be passed via CFLAGS (e.g. -DTOKMAK_PLATFORM_PICO=1)
#define TOKMAK_PLATFORM_PICO 1

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
