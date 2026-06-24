// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Tokmak",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "SwiftUI",
      targets: ["SwiftUI"]
    ),
    .library(
      name: "TokmakStaticHTML",
      targets: ["TokmakStaticHTML"]
    ),
    .library(
      name: "TokmakDOM",
      targets: ["TokmakDOM"]
    ),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "SwiftUI",
      dependencies: [
      ]
    ),
    .target(
      name: "TokmakStaticHTML",
      dependencies: ["SwiftUI"]
    ),
    .target(
      name: "TokmakDOM",
      dependencies: ["SwiftUI", "TokmakStaticHTML"]
    ),
    .executableTarget(
      name: "TokmakWebDemo",
      dependencies: ["SwiftUI", "TokmakDOM", "TokmakWebRuntime"]
    ),
    .target(
      name: "TokmakWebRuntime",
      path: "Sources/TokmakWebRuntime",
      publicHeadersPath: "include"
    ),
    .testTarget(
      name: "SwiftUITests",
      dependencies: ["SwiftUI"]
    ),
    .testTarget(
      name: "TokmakStaticHTMLTests",
      dependencies: ["SwiftUI", "TokmakStaticHTML"]
    ),
  ]
)
