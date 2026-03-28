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
        .product(name: "BaseMacros", package: "BaseMacros")
      ],
    ),
    .target(
      name: "GestureKit",
      dependencies: [
        .module(.interactionPrimitives)
      ],
    ),
    .target(
      name: "LilyPad",
      dependencies: [
        .module(.interactionPrimitives)
      ],
    ),
    .testTarget(
      name: "GestureKitTests",
      dependencies: ["GestureKit"],
    ),
  ],
)

extension Target.Dependency {
  static func module(_ baseModule: BaseModule) -> Self {
    .target(name: baseModule.name)
  }
}
extension String { static let baseHelpers = "BaseHelpers" }

enum BaseModule {
  case interactionPrimitives

  var name: String {
    switch self {
      case .interactionPrimitives: ("InteractionPrimitives")
    }
  }
}
