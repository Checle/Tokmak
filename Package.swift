// swift-tools-version:5.6

import PackageDescription

#if os(macOS)
let SDLCFlags = ["-I/opt/homebrew/include"]
#else
let SDLCFlags = [String]()
#endif

let package = Package(
  name: "Tokmak",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
  ],
  products: [
    .library(name: "CLVGL", targets: ["CLVGL"]),
    .library(
      name: "TokmakLVGL",
      targets: ["TokmakLVGL"]
    ),
    .library(
      name: "TokmakShim",
      targets: ["TokmakShim"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/OpenCombine/OpenCombine.git",
      from: "0.12.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      from: "1.9.0"
    ),
  ],
  targets: [
    .target(
      name: "TokmakCore",
      dependencies: [
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        ),
      ]
    ),
    .target(
      name: "TokmakShim",
      dependencies: [
        .target(name: "TokmakLVGL"),
      ]
    ),
    .target(
      name: "CLVGL",
      dependencies: [],
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("lv_drivers"),
        .headerSearchPath("lvgl"),
        .headerSearchPath("."),
        .unsafeFlags(SDLCFlags + ["-DLV_LVGL_H_INCLUDE_SIMPLE"]),
      ],
      linkerSettings: [.unsafeFlags(["-L/opt/homebrew/lib", "-lSDL2"])]
    ),
    .target(
      name: "TokmakLVGL",
      dependencies: [
        "TokmakCore", "CLVGL",
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        ),
      ]
    ),
    .target(
      name: "TokmakTestRenderer",
      dependencies: ["TokmakCore"]
    ),
    .testTarget(
      name: "TokmakLayoutTests",
      dependencies: [
        "TokmakCore",
        .product(
          name: "SnapshotTesting",
          package: "swift-snapshot-testing",
          condition: .when(platforms: [.macOS])
        ),
      ]
    ),
    .testTarget(
      name: "TokmakReconcilerTests",
      dependencies: [
        "TokmakCore",
        "TokmakTestRenderer",
      ]
    ),
    .testTarget(
      name: "TokmakTests",
      dependencies: ["TokmakTestRenderer"]
    ),
  ]
)
