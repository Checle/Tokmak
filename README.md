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
    .package(url: "https://github.com/YOUR_USERNAME/Tokmak.git", branch: "main")
]
```

## Hardware Integration (E-Paper / Display Bridge)

TokmakUI completely abstracts away LVGL's C pointers (`lv_disp_drv_t`, `lv_disp_draw_buf_t`). You simply pass a `DisplayConfiguration` to `MyApp.main(display:)`. TokmakUI will internally allocate the LVGL C structs, register the C-to-Swift closure bridges, and start the render loop.

Here is a complete example of how to initialize TokmakUI for a hardware display (like an E-Paper screen) from your top-level Embedded Swift project:

```swift
import TokmakUI
import CLVGL // Only needed if you need to use the lv_color_t type directly

let epdWidth = 800
let epdHeight = 480

// 1. Allocate your drawing buffer statically
// (e.g. 20 lines of height for the LVGL draw buffer)
var lvBuf = [lv_color_t](repeating: .init(full: 0), count: epdWidth * 20)

// 2. Define your hardware-specific framebuffer (for 1-bit E-Paper)
var epd_fb = [UInt8](repeating: 0, count: (epdWidth * epdHeight) / 8)

// 3. Create the Display Configuration
let displayConfig = DisplayConfiguration(
    width: epdWidth,
    height: epdHeight,
    drawBuffer: UnsafeMutableBufferPointer(start: &lvBuf, count: lvBuf.count)
) { area, colors in
    // This closure is called by TokmakUI when LVGL needs to flush pixels.
    // It is pure Swift! No LVGL C pointers required.
    
    var colorIndex = 0
    for y in area.minY...area.maxY {
        for x in area.minX...area.maxX {
            let index = (x + y * epdWidth) / 8
            let bit = 7 - (x % 8)

            // Map LVGL colors to your E-Paper bit depth
            if colors[colorIndex].full == 1 { // White
                epd_fb[index] |= (1 << bit)
            } else { // Black
                epd_fb[index] &= ~(1 << bit)
            }

            colorIndex += 1
        }
    }

    // Call your specific hardware SPI/HAL function to update the display
    // epd_displayBW_partial_region(&epd_fb, area.minX, area.minY, area.maxX, area.maxY)
}

// 4. Define your UI
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Hello E-Paper from Embedded Swift!")
        }
    }
}

// 5. Launch the application with the hardware config
MyApp.main(display: displayConfig)
```

## License

Apache 2.0. See [LICENSE](LICENSE) for details.
