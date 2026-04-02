//
//  BFP+Normalise.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/8/2025.
//

import Foundation

extension BinaryFloatingPoint {

  /// Returns zero if range width is zero
  public func normalised(in range: ClosedRange<Self>) -> Self {
    normalisedIfValid(in: range) ?? 0
  }

  /// Normalise converts a value in a range to `0.0` to `1.0`:
  /// `fraction = (position - min) / (max - min) ()`
  ///
  /// Denormalise converts a `0.0` to `1.0` fraction
  /// back to the original range:
  /// `value = min + fraction * (max - min)`
  /// Converts a value in the given range into a fraction between 0.0 and 1.0.
  /// Values below/above the range will be clamped.
  public func normalisedIfValid(in range: ClosedRange<Self>) -> Self? {
    guard range.isGreaterThanZero else { return nil }
    let clamped = clamped(to: range)
    return (clamped - range.lowerBound) / (range.upperBound - range.lowerBound)
  }

  /// Returns zero if range width is zero
  public func denormalised(in range: ClosedRange<Self>) -> Self {
    denormalisedIfValid(in: range) ?? 0
  }

  /// Converts a normalised fraction (between 0.0 and 1.0)
  /// back to a value within the given range.
  /// Fractions outside 0.0-1.0 will extend beyond the range proportionally.
  public func denormalisedIfValid(in range: ClosedRange<Self>) -> Self? {
    guard range.isGreaterThanZero else { return nil }
    return range.lowerBound + self * (range.upperBound - range.lowerBound)
  }

}
