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

## Hardware Integration (E-Paper / Display Bridge)

Tokmak uses a "Zero-Overhead" hardware abstraction layer for MCU integration. Instead of passing dynamic closures, Tokmak defines its target hardware via C macro constants (e.g., `-DTOKMAK_PLATFORM_PICO=1`) and expects the application to provide specific external symbols (like `gpio_put` or `sleep_ms`) at link-time.

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

To satisfy the linker on your MCU, you provide a simple C file defining your physical pins and bridging any SDK functions:

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

## License

Apache 2.0. See [LICENSE](LICENSE) for details.
