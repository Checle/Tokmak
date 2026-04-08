#include "epd_uc8253.h"
#include <stddef.h>

// -----------------------------------------------------------------------------
// Hardware Abstraction via External Symbols
// -----------------------------------------------------------------------------
#if TOKMAK_PLATFORM_PICO && TOKMAK_PLATFORM_ESP_IDF
#error "Only one embedded platform macro can be enabled at a time."
#elif TOKMAK_PLATFORM_PICO

// External functions expected to be provided by the Raspberry Pi Pico SDK
extern void sleep_ms(uint32_t ms);
extern void gpio_put(uint32_t gpio, bool value);
extern bool gpio_get(uint32_t gpio);
extern void spi_write_blocking(void *spi, const uint8_t *src, size_t len);

// External pin configuration expected to be defined in the user's application
extern const uint32_t TOKMAK_PIN_DC;
extern const uint32_t TOKMAK_PIN_RST;
extern const uint32_t TOKMAK_PIN_CS;
extern const uint32_t TOKMAK_PIN_BUSY;
extern void* TOKMAK_SPI_PORT;

static void wait_until_idle(void) {
    while (gpio_get(TOKMAK_PIN_BUSY) == 1) {
        sleep_ms(10);
    }
}

static void epd_send_cmd(uint8_t command) {
    gpio_put(TOKMAK_PIN_DC, false);
    gpio_put(TOKMAK_PIN_CS, false);
    spi_write_blocking(TOKMAK_SPI_PORT, &command, 1);
    gpio_put(TOKMAK_PIN_CS, true);
}

static void epd_send_data(uint8_t data) {
    gpio_put(TOKMAK_PIN_DC, true);
    gpio_put(TOKMAK_PIN_CS, false);
    spi_write_blocking(TOKMAK_SPI_PORT, &data, 1);
    gpio_put(TOKMAK_PIN_CS, true);
}

static void delay_ms(uint32_t ms) {
    sleep_ms(ms);
}

static void set_rst(bool state) {
    gpio_put(TOKMAK_PIN_RST, state);
}

#elif TOKMAK_PLATFORM_ESP_IDF

// External bridge functions expected to be provided by the ESP-IDF application.
// The application owns the actual ESP-IDF handles and links against ESP-IDF.
extern void tokmak_esp_idf_delay_ms(uint32_t ms);
extern void tokmak_esp_idf_gpio_set_level(uint32_t gpio, bool value);
extern bool tokmak_esp_idf_gpio_get_level(uint32_t gpio);
extern void tokmak_esp_idf_spi_write(const uint8_t *src, size_t len);

extern const uint32_t TOKMAK_PIN_DC;
extern const uint32_t TOKMAK_PIN_RST;
extern const uint32_t TOKMAK_PIN_CS;
extern const uint32_t TOKMAK_PIN_BUSY;

static void wait_until_idle(void) {
    while (tokmak_esp_idf_gpio_get_level(TOKMAK_PIN_BUSY) == 1) {
        tokmak_esp_idf_delay_ms(10);
    }
}

static void epd_send_cmd(uint8_t command) {
    tokmak_esp_idf_gpio_set_level(TOKMAK_PIN_DC, false);
    tokmak_esp_idf_gpio_set_level(TOKMAK_PIN_CS, false);
    tokmak_esp_idf_spi_write(&command, 1);
    tokmak_esp_idf_gpio_set_level(TOKMAK_PIN_CS, true);
}

static void epd_send_data(uint8_t data) {
    tokmak_esp_idf_gpio_set_level(TOKMAK_PIN_DC, true);
    tokmak_esp_idf_gpio_set_level(TOKMAK_PIN_CS, false);
    tokmak_esp_idf_spi_write(&data, 1);
    tokmak_esp_idf_gpio_set_level(TOKMAK_PIN_CS, true);
}

static void delay_ms(uint32_t ms) {
    tokmak_esp_idf_delay_ms(ms);
}

static void set_rst(bool state) {
    tokmak_esp_idf_gpio_set_level(TOKMAK_PIN_RST, state);
}

#else

// Stubs for unknown platforms / macOS compilation
static void wait_until_idle(void) {}
static void epd_send_cmd(uint8_t command) {}
static void epd_send_data(uint8_t data) {}
static void delay_ms(uint32_t ms) {}
static void set_rst(bool state) {}

#endif
// -----------------------------------------------------------------------------

static void epd_power_on(void) {
    epd_send_cmd(0x04);
    wait_until_idle();
}

static void epd_power_off(void) {
    epd_send_cmd(0x02);
    wait_until_idle();
}

static void epd_panel_setting(void) {
    epd_send_cmd(0x00); // PANEL SETTING
    epd_send_data(0x1f);
    epd_send_data(0x0d);
}

void epd_uc8253_init(void) {
    set_rst(false);
    delay_ms(10);
    set_rst(true);
    delay_ms(10);
    wait_until_idle();

    epd_panel_setting();
}

void epd_uc8253_init_partial(void) {
    epd_uc8253_init();
}

void epd_uc8253_sleep(void) {
    epd_power_off();
    epd_send_cmd(0x07); // deep sleep
    epd_send_data(0xA5); // check code
}

void epd_uc8253_clear(void) {
    int w = EPD_UC8253_WIDTH;
    int h = EPD_UC8253_HEIGHT;
    
    epd_send_cmd(0x10); // Set previous buffer
    for (int i = 0; i < (w * h) / 8; i++) {
        epd_send_data(0xFF); // White
    }
    
    epd_send_cmd(0x13); // Set current buffer
    for (int i = 0; i < (w * h) / 8; i++) {
        epd_send_data(0xFF); // White
    }
    
    // Fast Full Update settings
    epd_send_cmd(0xE0); // Cascade Setting
    epd_send_data(0x02); // TSFIX
    epd_send_cmd(0xE5); // Force Temperature
    epd_send_data(0x5A); // 1005000us
    
    epd_send_cmd(0x50);
    epd_send_data(0x97);
    
    epd_power_on();
    epd_send_cmd(0x12); // Display Refresh
    wait_until_idle();
    epd_power_off();
    
    epd_panel_setting(); // Undo TSFIX
}

static void set_window(int x, int y, int w, int h) {
    int x1 = x & 0xFFF8; // Byte boundary
    int xe = (x + w - 1) | 0x0007; // Byte boundary inclusive
    int ye = y + h - 1;

    epd_send_cmd(0x90); // Partial window
    epd_send_data(x1);
    epd_send_data(xe);
    epd_send_data(y / 256);
    epd_send_data(y % 256);
    epd_send_data(ye / 256);
    epd_send_data(ye % 256);
    epd_send_data(0x01);
}

void epd_uc8253_update_region(const uint8_t *buffer, int x, int y, int w, int h, epd_update_mode_t mode) {
    epd_send_cmd(0x91); // partial in
    set_window(x, y, w, h);
    
    epd_send_cmd(0x13);
    int bytes = ((w + 7) / 8) * h;
    for (int i = 0; i < bytes; i++) {
        epd_send_data(buffer[i]);
    }

    if (mode == EPD_MODE_PARTIAL) {
        epd_send_cmd(0xE0); // Cascade Setting
        epd_send_data(0x02); // TSFIX
        epd_send_cmd(0xE5); // Force Temperature
        epd_send_data(0x6E);
        
        epd_send_cmd(0x50);
        epd_send_data(0xD7);
    } else {
        epd_send_cmd(0xE0); // Cascade Setting
        epd_send_data(0x02); // TSFIX
        epd_send_cmd(0xE5); // Force Temperature
        epd_send_data(0x5A);
        
        epd_send_cmd(0x50);
        epd_send_data(0x97);
    }
    
    epd_power_on();
    epd_send_cmd(0x12); // Display refresh
    wait_until_idle();
    epd_power_off();
    
    epd_panel_setting(); // Undo TSFIX
    
    epd_send_cmd(0x92); // partial out
}
