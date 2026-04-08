// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "TokmakESPIDFExample",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "TokmakESPIDFApp",
      type: .static,
      targets: ["TokmakESPIDFApp"]
    ),
  ],
  dependencies: [
    .package(path: "../../.."),
  ],
  targets: [
    .target(
      name: "TokmakESPIDFApp",
      dependencies: [
        .product(name: "TokmakUI", package: "Tokmak"),
      ]
    ),
  ]
)
