# Tokmak

A SwiftUI-compatible framework for building applications on Embedded Swift (MCUs) using LVGL.

This repository is a radical fork of [Tokamak](https://github.com/TokamakUI/Tokamak), stripped down and specifically redesigned to provide a lightweight, static, and reflection-free UI tree for microcontrollers using Swift Embedded.

## Overview

Unlike standard SwiftUI or the original Tokamak framework which rely heavily on runtime reflection and dynamic heap allocations:
- **No Reflection:** `@State` and `@Environment` bindings are mapped using a static `PropertyVisitor` pattern.
- **Embedded Swift Compatible:** Designed to compile cleanly as a Swift Embedded dependency.
- **LVGL Backend:** Rendered using the popular C-based LVGL embedded graphics library.

## Usage

Tokmak is designed to be used primarily as a package dependency in your Swift Embedded project.

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/Checle/Tokmak.git", branch: "main")
]
```

## Running the Simulator

You can instantly test your Tokmak UI layouts natively on macOS or Linux using the built-in SDL2 simulator.

First, ensure you have SDL2 installed:
- **macOS (Homebrew):** `brew install sdl2`
- **macOS (MacPorts):** `sudo port install libsdl2`
- **Linux (Ubuntu/Debian):** `sudo apt install libsdl2-dev`

Then, simply run the included example executable:

```bash
swift run TokmakExample
```

## Embedded Build Checks

There are two useful levels of build validation:

1. A source-level Embedded Swift sanity check, run from the host toolchain.
2. A real MCU cross-build, using an embedded Swift SDK / sysroot and your hardware SDK.

The first check is useful because it catches host-only imports and APIs early:

```bash
swift build -c release \
  -Xswiftc -wmo \
  -Xswiftc -enable-experimental-feature \
  -Xswiftc Embedded \
  -Xcc -DTOKMAK_PLATFORM_PICO=1 \
  -Xswiftc -DTOKMAK_PLATFORM_PICO
```

For ESP-IDF-backed builds, use the ESP-IDF platform macro instead:

```bash
swift build -c release \
  -Xswiftc -wmo \
  -Xswiftc -enable-experimental-feature \
  -Xswiftc Embedded \
  -Xcc -DTOKMAK_PLATFORM_ESP_IDF=1 \
  -Xswiftc -DTOKMAK_PLATFORM_ESP_IDF
```

This does not produce a Pi Pico binary. It only verifies that the Swift package itself is not accidentally pulling in desktop-only code paths while `TOKMAK_PLATFORM_PICO` is enabled.

When run against a desktop target triple, this check can still fail with `module 'Swift' cannot be imported in embedded Swift mode`. That reflects the host toolchain / target combination, not necessarily a Tokmak source issue. Use it to catch package-structure regressions, not as proof of a successful MCU build.

For a real MCU build, use an embedded target triple plus a matching C sysroot / Swift SDK. For example:

```bash
swift build --triple armv6m-none-none-eabi -c release \
  -Xswiftc -wmo \
  -Xswiftc -enable-experimental-feature \
  -Xswiftc Embedded \
  -Xcc -DTOKMAK_PLATFORM_PICO=1 \
  -Xswiftc -DTOKMAK_PLATFORM_PICO
```

Without an installed embedded SDK / sysroot, the cross-build will fail early on standard C headers such as `string.h`. That failure means the toolchain environment is incomplete, not that Tokmak's Pico integration model is invalid.

## Hardware Integration (E-Paper / Display Bridge)

Tokmak uses a "Zero-Overhead" hardware abstraction layer for MCU integration. Instead of passing dynamic closures, Tokmak defines its target hardware via C macro constants (for example, `-DTOKMAK_PLATFORM_PICO=1` or `-DTOKMAK_PLATFORM_ESP_IDF=1`) and expects the application to provide specific external symbols at link-time.

Here is an example of an application entry point for the Raspberry Pi Pico and the GDEY037T03 e-paper display:

```swift
import TokmakUI

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Hello E-Paper!")
                Spacer()
                Button("Click Me") {
                    print("Button was clicked")
                }
            }
            .padding(20)
            .frame(width: 240, height: 416)
        }
    }
}

// Launches the app. On an MCU, this automatically wires up the C display driver 
// and your statically linked hardware pins. On a desktop, it opens an SDL window.
MyApp.main()
```

To satisfy the linker on your MCU, you provide a small C file owned by the final firmware target. That target links against the actual hardware SDK. Tokmak itself should not directly own the Pico SDK or ESP-IDF link step.

### Raspberry Pi Pico

For Raspberry Pi Pico, you provide the physical pins and the SPI instance:

```c
// hardware.c
#include "pico/stdlib.h"
#include "hardware/spi.h"

// Define the physical pins expected by Tokmak's E-Paper driver
const uint32_t TOKMAK_PIN_DC   = 8;
const uint32_t TOKMAK_PIN_CS   = 9;
const uint32_t TOKMAK_PIN_RST  = 12;
const uint32_t TOKMAK_PIN_BUSY = 13;
void* TOKMAK_SPI_PORT = spi1;

// The driver will automatically use `gpio_put`, `sleep_ms`, etc., from the Pico SDK!
```

### ESP-IDF

For ESP-IDF, the application provides a tiny bridge layer. Tokmak does not include ESP-IDF headers itself; the firmware target does.

```c
// hardware_bridge.c
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#include "driver/gpio.h"
#include "driver/spi_master.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

const uint32_t TOKMAK_PIN_DC   = 4;
const uint32_t TOKMAK_PIN_CS   = 5;
const uint32_t TOKMAK_PIN_RST  = 6;
const uint32_t TOKMAK_PIN_BUSY = 7;

extern spi_device_handle_t tokmak_epd_spi;

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
    spi_device_polling_transmit(tokmak_epd_spi, &transaction);
}
```

In an ESP-IDF project, the final firmware target should link the ESP-IDF components and build Tokmak as part of the project, typically using ESP-IDF's CMake component model. The build-system overview is documented by Espressif: https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html

## License

Apache 2.0. See [LICENSE](LICENSE) for details.
