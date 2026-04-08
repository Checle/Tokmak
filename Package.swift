// swift-tools-version:5.6

import PackageDescription

#if os(macOS)
let sdlCFlags = ["-I/opt/homebrew/include", "-I/opt/local/include"]
let sdlLinkerFlags = ["-L/opt/homebrew/lib", "-L/opt/local/lib", "-lSDL2"]
#elseif os(Linux)
let sdlCFlags = ["-I/usr/include/SDL2", "-D_REENTRANT"]
let sdlLinkerFlags = ["-lSDL2"]
#else
let sdlCFlags = [String]()
let sdlLinkerFlags = [String]()
#endif

let simulatorCondition: BuildSettingCondition? = .when(platforms: [
  .macOS,
  .linux,
])

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
      exclude: [
        "lvgl/.github",
        "lvgl/demos",
        "lvgl/docs",
        "lvgl/env_support",
        "lvgl/examples",
        "lvgl/scripts",
        "lvgl/tests",
      ],
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("lvgl"),
        .headerSearchPath("."),
        .unsafeFlags(["-DLV_LVGL_H_INCLUDE_SIMPLE"]),
        .unsafeFlags(sdlCFlags, simulatorCondition),
      ],
      linkerSettings: [
        .unsafeFlags(sdlLinkerFlags, simulatorCondition),
      ]
    ),
  ]
)
