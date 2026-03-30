//
//  GridRounding.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/10/2025.
//

import Foundation

/// ## Rounding options for fitting measurements into grid columns
///
/// When aligning text or hit-testing within a fixed cell grid, it is important
/// to round values consistently to avoid overflow or underflow beyond the grid edges.
///
/// - `.down`
///   Rounds toward zero (truncates) to ensure values never exceed the grid bounds.
/// - `.up`
///   Rounds upward (ceiling) to cover all visible pixels or reserve space for partial overlap.
/// - `.none`
///   Leaves the value unchanged.
///
/// Use cases include:
/// - Text measurement conversions to integer cell counts
/// - Hit-testing cell indices without overflow
/// - Visual alignment corrections and expansions
public enum GridRounding: String, Sendable {
  case down
  case up
  case none
  
  public var name: String { rawValue.capitalized }

  private var rule: FloatingPointRoundingRule? {
    switch self {
      case .down: .towardZero
      case .up: .up
      case .none: nil
    }
  }

  /// Returns a CGFloat rounded using the selected GridRounding rule, or unchanged if `.none`.
  public func roundedIfNeeded(_ value: CGFloat) -> CGFloat {
    guard let rule else {
      return value
    }
    return value.rounded(rule)
  }

  /// Returns an integer by rounding the value using the selected GridRounding rule.
  public func roundedInt(_ value: CGFloat) -> Int {
    guard let rule else { return Int(value) }
    return Int(value.rounded(rule))
  }

  public func fractionalPart(_ value: CGFloat) -> CGFloat {
    return value - value.rounded(.towardZero)
  }
}

extension BinaryFloatingPoint {
  /// Returns a floating-point value rounded using the specified GridRounding rule.
  ///
  /// Example:
  /// ```
  /// let value: Double = 5.7
  /// let roundedDown = value.rounded(using: .down) // 5.0
  /// let roundedUp = value.rounded(using: .up)     // 6.0
  /// ```
  public func rounded(using gridRounding: GridRounding) -> Self {
    let rounded = gridRounding.roundedIfNeeded(CGFloat(self))
    return Self(rounded)
  }

  /// Returns an integer rounded using the specified GridRounding rule.
  ///
  /// Example:
  /// ```
  /// let value: Double = 5.7
  /// let intDown = value.roundedInt(using: .down) // 5
  /// let intUp = value.roundedInt(using: .up)     // 6
  /// ```
  public func roundedInt(using gridRounding: GridRounding) -> Int {
    return gridRounding.roundedInt(CGFloat(self))
  }
}

#warning("This seems like a duplicate of the above")
public enum SnapStrategy {
  case floor
  case ceil
  case round
}

extension SnapStrategy {
  func snapped<T: BinaryFloatingPoint>(_ value: T) -> T {
    switch self {
      case .floor:
        return Foundation.floor(value)
      case .ceil:
        return Foundation.ceil(value)
      case .round:
        return Foundation.round(value)
    }
  }

  func snapped(_ value: CGFloat) -> Int {
    switch self {
      case .floor:
        return Int(Foundation.floor(value))
      case .ceil:
        return Int(Foundation.ceil(value))
      case .round:
        return Int(Foundation.round(value))
    }
  }
}
