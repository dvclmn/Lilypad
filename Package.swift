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
        .extDependency(.enumMacros),
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
  static func module(_ name: InternalModule) -> Self {
    .target(name: name.name)
  }
  static func extDependency(_ dependency: ExternalDependency) -> Self {
    .product(
      name: dependency.reference.0,
      package: dependency.reference.1 ?? dependency.reference.0,
    )
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

enum ExternalDependency {
  case enumMacros

  var reference: (String, String?) {
    switch self {
      case .enumMacros: ("BaseMacros", nil)
    }
  }
}
