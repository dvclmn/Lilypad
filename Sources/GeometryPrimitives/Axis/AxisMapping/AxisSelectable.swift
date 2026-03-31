//
//  AxisSelectable.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/2/2026.
//

import SwiftUI

/// Useful for e.g. `Edge` and `Alignment`, which don't store values,
/// but rather represent directions.
public protocol AxisOrientable {
  /// Returns the equivalent value under a different axis mapping.
  func mapped(by mapping: AxisMapping) -> Self
}

extension Edge: AxisOrientable {
  public func mapped(by mapping: AxisMapping) -> Edge {
    guard mapping == .transposed else { return self }
    switch self {
      case .top: return .leading
      case .bottom: return .trailing
      case .leading: return .top
      case .trailing: return .bottom
    }
  }
}

/// ```
/// let layoutMapping: AxisMapping = .transposed
/// let baseAlignment: Alignment = .topLeading // (H: .leading, V: .top)
///
/// let resolved = baseAlignment.mapped(by: layoutMapping)
/// // Result: .topLeading
/// // Because:
/// // Old H (.leading) -> New V (.top)
/// // Old V (.top) -> New H (.leading)
/// // In a transpose, .topLeading stays .topLeading visually!
///
/// let topTrailing: Alignment = .topTrailing // (H: .trailing, V: .top)
/// let resolvedTrailing = topTrailing.mapped(by: layoutMapping)
/// // Result: .bottomLeading
/// // Old H (.trailing) -> New V (.bottom)
/// // Old V (.top) -> New H (.leading)
/// ```
extension Alignment: AxisOrientable {
  public func mapped(by mapping: AxisMapping) -> Alignment {
    /// If identity, return as-is.
    guard mapping == .transposed else { return self }

    /// Swap and Translate:
    /// 1. The old Horizontal becomes the new Vertical equivalent.
    /// 2. The old Vertical becomes the new Horizontal equivalent.
    return Alignment(
      horizontal: self.vertical.horizontalEquivalent,
      vertical: self.horizontal.verticalEquivalent
    )
  }
}

extension AxisMapping {
  /// Returns the physical Edge for a logical direction.
  /// - Parameter isPositive: `true` for trailing/bottom (max), `false` for leading/top (min).
  public func edge(for axis: GeometryAxis, isPositive: Bool) -> Edge {
    let physicalAxis = self.map(axis)
    switch (physicalAxis, isPositive) {
      case (.horizontal, false): return .leading
      case (.horizontal, true): return .trailing
      case (.vertical, false): return .top
      case (.vertical, true): return .bottom
    }
  }
}

//public protocol AxisSelectable {
//  associatedtype Component
//
//  func value(along axis: GridAxis, mapping: AxisMapping) -> Component
//  func setting(_ newValue: Component, along axis: GridAxis, mapping: AxisMapping) -> Self
//}
