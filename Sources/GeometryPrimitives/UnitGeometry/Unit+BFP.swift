//
//  Unit+BFP.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 27/2/2026.
//

import Foundation

extension BinaryFloatingPoint {

  /// Converts a float (screen) value, to an integer (grid) value,
  /// based on a unit reference point (`unitSize`).
  ///
  /// Because this method accepts
  /// a unit of type `CGSize`,  an `axis` is provided to
  /// specify which edge to use as the unit length.
  /// - Parameters:
  ///   - axis: The edge to use for the unit length, from `unitSize`
  ///   - unitSize: The size that defines a new reference point, where width == 1 unit wide, and height == 1 unit high
  ///   - rounding: Whether to round up or down, when converting floats to integers
  /// - Returns: An integer that represents the number of 'units' that can fit along the length of `self`
  public func toGridCount(
    using unitLength: CGFloat,
    rounding: GridRounding = .down
  ) -> Int? {
    guard isSafeToConvert(self, using : unitLength) else { return nil }
    let resultRounded = (CGFloat(self) / unitLength).rounded(using: rounding)
    return Int(resultRounded)
  }

  /// Returns `self`, but having gone through the `toGridCount`
  /// process, and then `toScreenLength`, resulting in a value
  /// that's still a float, but now 'quantised' to the integer equivalent
  public func snappedToGrid(
    using unitLength: CGFloat,
    rounding: GridRounding = .down
  ) -> Self {
    guard isSafeToConvert(self, using : unitLength),
      let gridCount = self.toGridCount(using: unitLength, rounding: rounding)
    else { return self }
    
    let result = gridCount.toScreenLength(using: unitLength)

    return Self(result)
  }
}
