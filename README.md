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

## Example

```swift
import TokmakCore
import TokmakLVGL

struct AppView: View {
    @State var count = 0

    var body: some View {
        Text("Hello from Tokmak on Embedded Swift!")
    }
}
```

## License

Apache 2.0. See [LICENSE](LICENSE) for details.
