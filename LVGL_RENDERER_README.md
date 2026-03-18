# TokamakLVGL - A Tokamak Renderer for LVGL

TokamakLVGL is a renderer that integrates the [Tokamak](https://github.com/TokamakUI/Tokamak) SwiftUI-like framework with [LVGL](https://docs.lvgl.io/), a popular open-source graphics library for embedded systems.

## Overview

LVGL (Light and Versatile Graphics Library) is a free and open-source embedded graphics library that makes it easy to create embedded GUIs with easy-to-use graphical elements, beautiful visual effects, and low memory footprint.

TokamakLVGL allows you to use Tokamak's declarative SwiftUI-like syntax to build UIs that render to LVGL, making it possible to:

- Build embedded UIs using familiar SwiftUI patterns
- Target embedded systems, microcontrollers, and embedded Linux devices
- Keep memory footprint low with LVGL's efficient rendering
- Use Swift code on embedded platforms

## Architecture

TokamakLVGL follows the same renderer architecture as other Tokamak renderers:

- **LVGLRenderer**: Implements the `Renderer` protocol from TokamakCore
- **AnyLVGLWidget Protocol**: Bridges Tokamak views to LVGL objects
- **View Implementations**: Each Tokamak view type that support LVGL rendering implements `AnyLVGLWidget`

```
Tokamak App
    ↓
StackReconciler
    ↓
LVGLRenderer
    ↓
LVGL C Library
    ↓
Display Driver
```

## Supported Views

Currently implemented:
- **Text**: Rendered as LVGL label (`lv_label`)

Planned:
- Button
- VStack / HStack / ZStack (container layouts)
- ScrollView
- Image
- Rectangle and other shapes
- TextField
- Toggle
- List / Picker

## Installation

### Prerequisites

Install LVGL development libraries:

**macOS:**
```bash
brew install lvgl
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get install liblvgl-dev
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install lvgl-devel
```

### Adding to Your Package

Add TokamakLVGL as a dependency in your `Package.swift`:

```swift
.target(
  name: "YourApp",
  dependencies: ["TokamakLVGL"]
)
```

## Getting Started

### Basic Example

```swift
import TokamakLVGL

struct MyApp: App {
  var body: some Scene {
    WindowGroup("My LVGL App") {
      VStack {
        Text("Hello, LVGL!")
        Text("Built with Tokamak")
      }
    }
  }
}

@main
struct Main {
  static func main() {
    MyApp.main()
  }
}
```

### Display Driver Setup

Before running a TokamakLVGL app, you need to initialize LVGL's display driver. This is typically done at the C level or using LVGL's driver libraries for your specific platform.

```c
// Example setup (platform-specific)
lv_disp_drv_t disp_drv;
lv_disp_drv_init(&disp_drv);
// Configure display driver based on your hardware
lv_disp_drv_register(&disp_drv);
```

## Implementation Details

### LVGLRenderer

The core renderer that manages the relationship between Tokamak's view tree and LVGL objects:

- **mountTarget**: Creates LVGL objects (lv_obj_t) when views are mounted
- **update**: Updates LVGL objects when SwiftUI state changes
- **unmount**: Destroys LVGL objects when views are removed

### Text View Implementation

Text views are rendered as LVGL labels:

```swift
extension Text: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer) -> UnsafeMutablePointer<lv_obj_t> {
    let label = lv_label_create(lv_scr_act())
    let text = _TextProxy(self).rawText
    text.withCString { cString in
      lv_label_set_text(label, cString)
    }
    return label
  }
}
```

## Extending TokamakLVGL

To add support for additional views:

1. Create a new file in `Sources/TokamakLVGL/Views/`
2. Extend the view to conform to `AnyLVGLWidget`
3. Implement `new()` to create the LVGL object
4. Implement `update()` to handle state changes

Example - Adding Button support:

```swift
extension Button: AnyLVGLWidget {
  func new(_ renderer: LVGLRenderer) -> UnsafeMutablePointer<lv_obj_t> {
    let button = lv_btn_create(lv_scr_act())
    let label = lv_label_create(button)
    
    // Set button text
    // ... 
    
    return button
  }
  
  func update(widget: LVGLWidget) {
    if case let .widget(w) = widget.storage {
      // Update button state
      // ...
    }
  }
}
```

## LVGL C Bindings

TokamakLVGL uses CLVGL, a system library that provides Swift bindings to LVGL's C API:

- **Sources/CLVGL/module.modulemap**: Maps LVGL C headers to Swift
- **Sources/CLVGL/include/lvgl_shim.h**: Shim header that includes LVGL

## Rebuilding the Renderer Bridge

The fundamental bridge between Tokamak and LVGL relies on:

1. `mapAnyView`: A TokamakCore function that extracts known types from view hierarchies
2. `AnyLVGLWidget`: Protocol that standardizes LVGL widget creation and updates
3. `StackReconciler`: Manages the recursive tree of widgets

## Next Steps

To enhance TokamakLVGL:

1. Implement additional view types (Button, Stack layouts, etc.)
2. Add styling and modifier support
3. Create display driver templates for popular platforms
4. Add theme and color customization
5. Implement keyboard and touch input handling
6. Add performance optimizations for embedded systems

## Resources

- [LVGL Documentation](https://docs.lvgl.io/)
- [Tokamak Repository](https://github.com/TokamakUI/Tokamak)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

## License

TokamakLVGL is licensed under the Apache License 2.0, same as Tokamak.
