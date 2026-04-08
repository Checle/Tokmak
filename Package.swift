// swift-tools-version:5.6

import PackageDescription

#if os(macOS)
let SDLCFlags = ["-I/opt/homebrew/include", "-I/opt/local/include"]
let SDLLinkerFlags = ["-L/opt/homebrew/lib", "-L/opt/local/lib", "-lSDL2"]
#elseif os(Linux)
let SDLCFlags = ["-I/usr/include/SDL2", "-D_REENTRANT"]
let SDLLinkerFlags = ["-lSDL2"]
#else
let SDLCFlags = [String]()
let SDLLinkerFlags = [String]()
#endif

let package = Package(
  name: "Tokmak",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
  ],
  products: [
    .executable(name: "TokmakExample", targets: ["TokmakExample"]),
    .library(name: "CLVGL", targets: ["CLVGL"]),
    .library(
      name: "TokmakUI",
      targets: ["TokmakUI"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .executableTarget(
      name: "TokmakExample",
      dependencies: ["TokmakUI"]
    ),
    .target(
      name: "TokmakUI",
      dependencies: [
        "CLVGL",
      ]
    ),
    .target(
      name: "CLVGL",
      dependencies: [],
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("lvgl"),
        .headerSearchPath("."),
        .unsafeFlags(SDLCFlags + ["-DLV_LVGL_H_INCLUDE_SIMPLE"]),
      ],
      linkerSettings: [.unsafeFlags(SDLLinkerFlags)]
    ),
  ]
)
