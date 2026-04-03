//
//  BrushStyle.swift
//  LilyPadDemo
//

import CoreGraphics

/// Configuration for how a stroke's visual width relates to drawing speed.
///
/// Slower, deliberate strokes get a wider line; faster strokes thin out.
/// This is the natural calligraphy/brush feel — the speed curve lets you
/// dial in how dramatic that effect is.
///
/// ## Tuning tips
///
/// - Raise ``maxWidth`` for a more painterly, expressive stroke.
/// - Lower ``speedCurve`` (toward 0) for a more dramatic taper — even a
///   small speed increase quickly narrows the stroke.
/// - Raise ``speedCurve`` (toward 1) for a more linear, subtle effect.
/// - ``maxSpeed`` should be calibrated to typical fast strokes on your
///   trackpad. Values around 1000–2000 pt/s work well in practice.
///
public struct BrushStyle: Sendable {
  /// Width when the finger is moving slowly or at rest.
  public var maxWidth: CGFloat

  /// Width when the finger is moving at or above `maxSpeed`.
  public var minWidth: CGFloat

  /// Speed (points/second) at which the stroke reaches its minimum width.
  /// Input above this value is clamped.
  public var maxSpeed: CGFloat

  /// Exponent applied to the normalised speed before mapping to width.
  /// Values < 1 produce a concave curve — width drops off quickly at low
  /// speeds then levels out. Values > 1 produce a convex curve.
  public var speedCurve: CGFloat

  public init(
    maxWidth: CGFloat = 18,
    minWidth: CGFloat = 1.5,
    maxSpeed: CGFloat = 1400,
    speedCurve: CGFloat = 0.45
  ) {
    self.maxWidth = maxWidth
    self.minWidth = minWidth
    self.maxSpeed = maxSpeed
    self.speedCurve = speedCurve
  }

  /// Returns the stroke width for a given scalar speed.
  public func width(for speed: CGFloat) -> CGFloat {
    let normalised = min(speed / maxSpeed, 1)
    let curved = pow(normalised, speedCurve)
    // Higher speed → higher curved → closer to minWidth
    return maxWidth - curved * (maxWidth - minWidth)
  }
}

extension BrushStyle {
  /// A thin, precise feel — suitable for inking or technical drawing.
  public static let precise = BrushStyle(maxWidth: 6, minWidth: 1, maxSpeed: 1200, speedCurve: 0.5)

  /// A loose, expressive brush — wide at rest, very thin when fast.
  public static let expressive = BrushStyle(maxWidth: 28, minWidth: 1, maxSpeed: 1600, speedCurve: 0.3)

  /// Uniform width — velocity has no effect. Useful for debugging or a
  /// pen-like feel.
  public static func constant(_ width: CGFloat) -> BrushStyle {
    BrushStyle(maxWidth: width, minWidth: width, maxSpeed: 1, speedCurve: 1)
  }
}
