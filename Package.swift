// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "InteractionKit",
  platforms: [
    .macOS("14.0")
  ],
  products: [
    .library(
      name: "InteractionKit",
      targets: [
        "GestureKit",
        "InteractionPrimitives",
        "GeometryPrimitives",
        "LilyPad",
      ],
    )
  ],
  dependencies: [
    .package(url: "https://github.com/dvclmn/BaseMacros", branch: "main")
  ],

  targets: [
    .target(
      name: "InteractionPrimitives",
      dependencies: [
        .product(name: "BaseMacros", package: "BaseMacros"),
        .module(.geometryPrimitives),
      ],
    ),
    .target(
      name: "GestureKit",
      dependencies: [
        .module(.interactionPrimitives)
      ],
    ),
    .target(
      name: "GeometryPrimitives"
    ),
    .target(
      name: "LilyPad",
      dependencies: [
        .module(.interactionPrimitives),
        .module(.geometryPrimitives),
      ],
    ),
    .testTarget(
      name: "GestureKitTests",
      dependencies: ["GestureKit"],
    ),
  ],
)

extension Target.Dependency {
  static func module(_ baseModule: InternalModule) -> Self {
    .target(name: baseModule.name)
  }
}
extension String { static let baseHelpers = "BaseHelpers" }

enum InternalModule {
  case interactionPrimitives
  case geometryPrimitives

  var name: String {
    switch self {
      case .interactionPrimitives: ("InteractionPrimitives")
      case .geometryPrimitives: ("GeometryPrimitives")
    }
  }
}
