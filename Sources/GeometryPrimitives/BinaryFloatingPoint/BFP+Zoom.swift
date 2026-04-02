//
//  BFP+Zoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 13/1/2026.
//

import Foundation

extension BinaryFloatingPoint {

  /// Multiplicative zoom factor: 1.0 == no zoom, 2.0 == 200%
  public func removingZoomFactor(_ factor: Self) -> Self {
    guard factor.isFinite, factor != 0 else { return self }
    return self / factor
  }

  /// Normalized zoom in 0...1 mapped to [1, maxFactor]
  public func removingZoomNormalised(
    _ normalised: Self,
    maxFactor: Self = 2,
  ) -> Self {
    let clamped = normalised.clamped(to: 0...1)
    let factor = 1 + clamped * (maxFactor - 1)
    return self / factor
  }

  /// Only for if `self` is a percent (0–100):
  public func removingZoomPercent(_ percent: Self) -> Self {
    precondition(percent >= 0 && percent <= 100, "Expects a 0...100 percent value, received: \(percent)")

    let normalised = percent / 100
    return self / (1 + normalised)
  }

  /// Keeps line width visually consistent across zoom levels.
  /// Optically, lines can feel slightly heavier at small zoom levels,
  /// and thinner when zoomed in close. Use `sensitivity`
  /// to adjust the feel of the weight at either extreme.
  ///
  /// A sensitivity of `0`/`nil` does not change the apparent
  /// line weight at all. A value of `1` will produce thinner lines
  /// at low zooms, and thicker lines at high zooms.
  public func removingZoom(
    _ zoom: Self,
    across range: ClosedRange<Self>? = nil,
    sensitivity: Self? = nil,
  ) -> Self {
    guard zoom.isGreaterThanZero, range?.isGreaterThanZero ?? false else {
      return self
    }
    let effectiveZoom = range.map { zoom.clamped(to: $0) } ?? zoom

    if let sensitivity {
      let s = sensitivity.clamped(to: 0...1)
      return self * Self(pow(Double(effectiveZoom), Double(s - 1)))
    }

    return self / effectiveZoom
  }

  /// This removes a zoom range which has been normalised from 0-1

  /// Applies non-linear zoom scaling to provide better control at different zoom levels
  /// - Parameters:
  ///   - zoomLevel: The current zoom level (0.1...60)
  ///   - zoomRange: The valid zoom range
  ///   - lowSensitivityThreshold: Zoom level below which sensitivity is reduced (default: 1.0)
  ///   - highSensitivityThreshold: Zoom level above which sensitivity is increased (default: 5.0)
  ///   - curve: The power curve factor (default: 1.5). Higher values = more dramatic curve
  /// - Returns: The transformed zoom scale to apply to the view
  public static func nonLinearZoomScale(
    _ zoom: Double,
    in range: ClosedRange<Double>,
    lowSensitivityThreshold: Double = 1.0,
    highSensitivityThreshold: Double = 5.0,
    curve: Double = 1.5,
  ) -> Double {

    guard range.isGreaterThanZero,
      curve > 0
    else { return zoom }

    let upper = range.upperBound
    let lower = range.lowerBound

    /// Normalise the zoom level to 0...1 range
    /// This method also clamps to range
    let normalised = zoom.normalised(in: range)

    /// Calculate threshold positions in normalised space
    /// Ensure no unexpected invalid values by clamping
    let low = lowSensitivityThreshold.clamped(to: range)
    let high = highSensitivityThreshold.clamped(to: range)

    let lowThresholdNorm = (low - lower) / (upper - lower)
    let highThresholdNorm = (high - lower) / (upper - lower)

    let transformedZoom: Double

    if normalised <= lowThresholdNorm {
      /// Low zoom range: reduce sensitivity (expand the curve - slower response)
      let localNorm = normalised / lowThresholdNorm

      /// Use curve to slow down response
      let slowed = CGFloat(curve).slowResponse(localNorm)

      transformedZoom = slowed * lowThresholdNorm

    } else if normalised >= highThresholdNorm {
      /// High zoom range: increase sensitivity (compress the curve - faster response)
      let localNorm = (normalised - highThresholdNorm) / (1.0 - highThresholdNorm)

      /// Inverse curve for faster response
      let faster = CGFloat(curve).fastResponse(localNorm)
      //      let compressed = pow(localNorm, 1.0 / curve)
      transformedZoom = highThresholdNorm + faster * (1.0 - highThresholdNorm)

    } else {
      /// Middle range: linear scaling
      transformedZoom = normalised
    }

    /// Convert back to actual zoom range
    return transformedZoom.denormalised(in: range)
    //    return transformedZoom * (upper - lower) + lower
  }

  /// Simplified non-linear zoom scaling using a single curve parameter
  /// - Parameters:
  ///   - zoom: The current zoom level
  ///   - range: The valid zoom range
  ///   - sensitivity: Controls the curve (values < 1.0 = less sensitive at low zoom, values > 1.0 = more sensitive at low zoom)
  /// - Returns: The transformed zoom scale
  public static func simpleNonLinearZoomScale(
    _ zoom: Double,
    range: ClosedRange<Double>,
    sensitivity: Double = 1.3,
  ) -> Double {
    guard sensitivity > 0 else { return zoom }
    let normalised = zoom.normalised(in: range)
    let transformed = pow(normalised, sensitivity)
    return transformed.denormalised(in: range)
  }

  /// Where self is the curve
  func slowResponse(_ x: Self) -> Self {
    Self(pow(CGFloat(x), CGFloat(self)))
  }

  /// Where self is the curve
  func fastResponse(_ x: Self) -> Self {
    Self(pow(CGFloat(x), CGFloat(1 / self)))
  }

}
