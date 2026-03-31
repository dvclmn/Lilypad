//
//  AxisKeyPathReadable.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/2/2026.
//

import Foundation

public protocol AxisKeyPathReadable {
  associatedtype Component

  /// Path to the first storage slot (e.g., .width, .x, .column)
  static var primaryKey: KeyPath<Self, Component> { get }

  /// Path to the second storage slot (e.g., .height, .y, .row)
  static var secondaryKey: KeyPath<Self, Component> { get }

//  func value(along axis: GeometryAxis, mapping: AxisMapping) -> Component
}
extension AxisKeyPathReadable {

  public func value(
    along axis: GeometryAxis,
    mapping: AxisMapping = .default,
  ) -> Component {
    
    /// Resolve which KeyPath to use based on the axis and the mapping
    let keyPath = mapping.select(
      primary: Self.primaryKey,
      secondary: Self.secondaryKey,
      for: axis
    )
    return self[keyPath: keyPath]
  }
}
