//
//  BFP+Normalise.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 11/8/2025.
//

import Foundation

extension BinaryFloatingPoint {

  /// For the latest regarding wrapping phase, see `VectorKit/WaveKit/Core`
  /// Could also be called `normalisedCycles`?
  /// Corrects negative phases and floating-point overflow
  /// `floor` returns the greatest integer less than or equal to `phase`
  /// `phase - floor(phase)` computes the fractional part of phase.
  ///
  /// This has some nice properties:
  /// - If phase is positive (e.g., `2.75`), `floor(2.75) = 2`, so `p = 0.75`
  /// - If phase is negative (e.g., `−0.25`), `floor(−0.25) = −1`,
  ///   so `p = −0.25 − (−1) = 0.75`. This effectively “wraps”
  ///   negative phases into the [0, 1) interval.
  /// - If phase is an integer (e.g., `3.0`), `p = 0.0`.
//  @inlinable
//  public static func normalisedPhase(_ phase: Self) -> Self {
//    let p = phase - floor(phase)
//
//    /// Clamp 1.0 to 0.0 (rare, but possible with floating point error)
//    return p >= 1.0 ? 0 : p
//  }
//
//  @inlinable
//  public static func normalisedRadians(_ radians: Self) -> Self {
//    let tau = Self.pi * 2
//    let r = radians.truncatingRemainder(dividingBy: tau)
//
//    // Map negative values into [0, 2π)
//    let p = r >= 0 ? r : r + tau
//
//    /// Clamp 2π to 0 (possible with FP error)
//    return p >= tau ? 0 : p
//  }

  /// Returns zero if range width is zero
  @inline(__always)
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

    /// See clamping helpers at `BaseHelpers/Extensions/All/Comparable`
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
