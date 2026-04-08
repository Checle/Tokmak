#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "esp_check.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

// Example board wiring. Adjust these values for your actual ESP target.
const uint32_t TOKMAK_PIN_DC = 4;
const uint32_t TOKMAK_PIN_CS = 5;
const uint32_t TOKMAK_PIN_RST = 6;
const uint32_t TOKMAK_PIN_BUSY = 7;

static const uint32_t TOKMAK_SPI_PIN_MOSI = 11;
static const uint32_t TOKMAK_SPI_PIN_SCLK = 12;
static const spi_host_device_t TOKMAK_SPI_HOST = SPI2_HOST;

spi_device_handle_t tokmak_epd_spi = NULL;

void tokmak_esp_idf_board_init(void) {
    gpio_config_t output_config = {
        .pin_bit_mask =
            (1ULL << TOKMAK_PIN_DC) |
            (1ULL << TOKMAK_PIN_CS) |
            (1ULL << TOKMAK_PIN_RST),
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };
    ESP_ERROR_CHECK(gpio_config(&output_config));

    gpio_config_t input_config = {
        .pin_bit_mask = (1ULL << TOKMAK_PIN_BUSY),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };
    ESP_ERROR_CHECK(gpio_config(&input_config));

    spi_bus_config_t bus_config = {
        .mosi_io_num = (int) TOKMAK_SPI_PIN_MOSI,
        .miso_io_num = -1,
        .sclk_io_num = (int) TOKMAK_SPI_PIN_SCLK,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = 4096,
    };
    ESP_ERROR_CHECK(spi_bus_initialize(TOKMAK_SPI_HOST, &bus_config, SPI_DMA_CH_AUTO));

    spi_device_interface_config_t device_config = {
        .clock_speed_hz = 4 * 1000 * 1000,
        .mode = 0,
        .spics_io_num = -1,
        .queue_size = 1,
    };
    ESP_ERROR_CHECK(spi_bus_add_device(TOKMAK_SPI_HOST, &device_config, &tokmak_epd_spi));

    gpio_set_level((gpio_num_t) TOKMAK_PIN_CS, 1);
    gpio_set_level((gpio_num_t) TOKMAK_PIN_RST, 1);
    gpio_set_level((gpio_num_t) TOKMAK_PIN_DC, 1);
}

void tokmak_esp_idf_delay_ms(uint32_t ms) {
    vTaskDelay(pdMS_TO_TICKS(ms));
}

void tokmak_esp_idf_gpio_set_level(uint32_t gpio, bool value) {
    gpio_set_level((gpio_num_t) gpio, value ? 1 : 0);
}

bool tokmak_esp_idf_gpio_get_level(uint32_t gpio) {
    return gpio_get_level((gpio_num_t) gpio) != 0;
}

void tokmak_esp_idf_spi_write(const uint8_t *src, size_t len) {
    spi_transaction_t transaction = {
        .length = len * 8,
        .tx_buffer = src,
    };
    ESP_ERROR_CHECK(spi_device_polling_transmit(tokmak_epd_spi, &transaction));
}
