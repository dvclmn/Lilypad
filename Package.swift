// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "Lilypad",
  platforms: [
    .macOS("14.0")
  ],
  products: [
    .library(
      name: "Lilypad",
      targets: ["Lilypad"],
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  ],

  targets: [
    .target(name: "Lilypad")
  ],
)
