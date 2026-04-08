#if defined(__APPLE__) || defined(__linux__)

#include "include/tokmak_sdl.h"
#include <SDL2/SDL.h>
#include <stdbool.h>

static SDL_Window * window = NULL;
static SDL_Renderer * renderer = NULL;
static SDL_Texture * texture = NULL;

static bool left_button_down = false;
static int last_x = 0;
static int last_y = 0;
static bool quit = false;

void tokmak_sdl_init(int width, int height) {
    SDL_Init(SDL_INIT_VIDEO);
    window = SDL_CreateWindow("Tokmak Simulator",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        width, height, 0);
    
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_SOFTWARE);
    
    // LVGL v8 uses ARGB8888 by default when depth is 32. 
    // If your LV_COLOR_DEPTH is 16, this needs to be SDL_PIXELFORMAT_RGB565.
    // For this bridge, we assume 32-bit color depth for the simulator.
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, width, height);
}

void tokmak_sdl_display_flush(lv_disp_drv_t * disp_drv, const lv_area_t * area, lv_color_t * color_p) {
    SDL_Rect rect;
    rect.x = area->x1;
    rect.y = area->y1;
    rect.w = area->x2 - area->x1 + 1;
    rect.h = area->y2 - area->y1 + 1;

    SDL_UpdateTexture(texture, &rect, color_p, rect.w * sizeof(lv_color_t));
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);

    lv_disp_flush_ready(disp_drv);
}

void tokmak_sdl_mouse_read(lv_indev_drv_t * indev_drv, lv_indev_data_t * data) {
    data->point.x = (int16_t)last_x;
    data->point.y = (int16_t)last_y;
    data->state = left_button_down ? LV_INDEV_STATE_PR : LV_INDEV_STATE_REL;
}

void tokmak_sdl_loop(void) {
    SDL_Event event;
    while (!quit) {
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_QUIT:
                    quit = true;
                    break;
                case SDL_MOUSEBUTTONDOWN:
                    if (event.button.button == SDL_BUTTON_LEFT) {
                        left_button_down = true;
                        last_x = event.button.x;
                        last_y = event.button.y;
                    }
                    break;
                case SDL_MOUSEBUTTONUP:
                    if (event.button.button == SDL_BUTTON_LEFT) {
                        left_button_down = false;
                        last_x = event.button.x;
                        last_y = event.button.y;
                    }
                    break;
                case SDL_MOUSEMOTION:
                    last_x = event.motion.x;
                    last_y = event.motion.y;
                    break;
            }
        }
        
        lv_timer_handler();
        SDL_Delay(5);
        lv_tick_inc(5);
    }
    
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

#endif