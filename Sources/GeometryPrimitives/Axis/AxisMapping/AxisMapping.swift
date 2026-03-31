//
//  Model+AxisConvention.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/9/2025.
//

import SwiftUI

/// Describes how a type's stored components map to logical axes.
///
/// Many types store two scalars in a fixed order (e.g. `CGSize` stores `(width, height)`,
/// `CGPoint` stores `(x, y)`). In most contexts, width/x correspond to the horizontal axis
/// and height/y to the vertical axis. In rotated or transposed contexts, this assumption
/// can be inverted. `AxisMapping` makes that relationship explicit.
///
/// - `.identity`: primary storage corresponds to horizontal; secondary to vertical.
/// - `.transposed`: primary storage corresponds to vertical; secondary to horizontal.
///
/// Thread an explicit `AxisMapping` into read/write helpers to keep axis-oriented code
/// correct even when coordinate systems are flipped.
public enum AxisMapping: Sendable {

  /// # Primary is Horizontal
  /// Normal: Width/Column is Horizontal, Height/Row is Vertical.
  /// Previously: `primaryIsHorizontal` / `widthIsHorizontal`
  case identity

  /// # Primary is Vertical
  /// Flipped: Width/Column is Vertical, Height/Row is Horizontal.
  /// Previously: `primaryIsVertical` / `heightIsHorizontal`
  case transposed

  /// Note: A third possible Axis could be 3D (Z-axis), this pattern could
  /// work by just adding a .depth case to the enums.

  /// The default mapping for typical Cartesian layouts (horizontal ↔ primary, vertical ↔ secondary).
  public static let `default`: Self = .identity

  /// Selects either `primary` or `secondary` based on `axis` and the current mapping.
  /// With `.identity`, `.horizontal` selects `primary` and `.vertical` selects `secondary`.
  /// With `.transposed`, this selection is flipped.
  public func select<T>(primary: T, secondary: T, for axis: GeometryAxis) -> T {
    switch (self, axis) {
      case (.identity, .horizontal), (.transposed, .vertical): return primary
      case (.identity, .vertical), (.transposed, .horizontal): return secondary
    }
  }

  /// Reorders `(h, v)` into `(primary, secondary)` according to the mapping.
  /// With `.identity` the result is `(h, v)`; with `.transposed` the result is `(v, h)`.
  public func pair<T>(h: T, v: T) -> (primary: T, secondary: T) {
    switch self {
      case .identity: return (h, v)
      case .transposed: return (v, h)
    }
  }

  /// Transforms a logical axis into a physical axis based on the mapping.
  public func map(_ axis: GeometryAxis) -> GeometryAxis {
    switch (self, axis) {
      case (.identity, let a): return a
      case (.transposed, .horizontal): return .vertical
      case (.transposed, .vertical): return .horizontal
    }
  }

  /// Converts a physical axis (SwiftUI.Axis) into your logical GeometryAxis.
  public func map(_ swiftUIAxis: Axis) -> GeometryAxis {
    let gridAxis = swiftUIAxis.toGeometryAxis
    return map(gridAxis)

  }
}

// MARK: - Deprecations
extension AxisMapping {

  /// Deprecated: Use `AxisMapping.identity`.
  @available(
    *, deprecated, renamed: "identity", message: "Renamed for clarity, please use `.identity` instead"
  )
  public static let primaryIsHorizontal: Self = .identity

  /// Deprecated: Use `AxisMapping.transposed`.
  @available(
    *, deprecated, renamed: "transposed", message: "Renamed for clarity, please use `.identity` instead"
  )
  public static let primaryIsVertical: Self = .transposed

}

/// A mapping between `Dimension` (width / height) and `Axis` (horizontal / vertical).
///
/// This aims to answer the question:
/// “Given this dimension-based structure, which scalar corresponds to which axis?”
///
/// In most cases, "width" means "horizontal" and "height" means "vertical".
/// But occasionally this is not the case (rotated coordinate systems, swapped
///  axes, certain drawing transforms), so it's risky to assume.
///
/// `AxisConvention` makes the convention explicit, so there's less risk of confusion
///
/// `.widthIsHorizontal`:
///    width → horizontal length
///    height → vertical length
///
/// `.heightIsHorizontal`:
///    height → horizontal length
///    width → vertical length
///
/// Enables deriving correct values from types like
/// `CGSize`, `CGPoint`, `EdgeInsets` etc
@available(
  *, deprecated, renamed: "AxisMapping", message: "Renamed for clarity, please use `AxisMapping` instead"
)
public enum AxisConvention: Sendable {

  case widthIsHorizontal
  case heightIsHorizontal

}
