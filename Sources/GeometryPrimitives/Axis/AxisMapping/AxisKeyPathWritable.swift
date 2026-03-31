//
//  AxisAddressable.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 15/12/2025.
//

import Foundation

/// Note: this requires that conforming types have mutable (var) properties
public protocol AxisKeyPathWritable: AxisKeyPathReadable {
    associatedtype Component

  /// Path to the first storage slot (e.g. `width`, `x`, `column`)
  static var primaryWritableKey: WritableKeyPath<Self, Component> { get }

  /// Path to the second storage slot (e.g. `height`, `y`, `row`)
  static var secondaryWritableKey: WritableKeyPath<Self, Component> { get }

//  func setting(
//    _ newValue: Component,
//    along axis: GeometryAxis,
//    mapping: AxisMapping
//  ) -> Self
}

extension AxisKeyPathWritable {
//  public typealias Component = Self.Component
  public static var primaryKey: KeyPath<Self, Component> { primaryWritableKey }
  public static var secondaryKey: KeyPath<Self, Component> { secondaryWritableKey }

  public func setting(
    _ newValue: Component,
    along axis: GeometryAxis,
    mapping: AxisMapping = .default
  ) -> Self {
    var copy = self
    let kp = mapping.select(
      primary: Self.primaryWritableKey,
      secondary: Self.secondaryWritableKey,
      for: axis
    )
    copy[keyPath: kp] = newValue
    return copy
  }
}
