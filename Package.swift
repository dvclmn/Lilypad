// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "Lilypad",
  platforms: [
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "Lilypad",
      targets: ["Lilypad"],
    )
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0")
  ],

  targets: [
    .target(name: "Lilypad"),
    .testTarget(name: "LilypadTests", dependencies: ["Lilypad"])
  ],
)
