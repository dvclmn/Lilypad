//
//  StrokePoint.swift
//  LilypadDemo
//

import Foundation

/// A single point in a stroke, capturing position and dynamics at the moment
/// of capture.
///
/// Richer than a bare `CGPoint` — preserves the speed and finger identity so
/// downstream rendering can vary width, opacity, or colour based on how the
/// user was moving. A future brush engine could extend this with pressure,
/// tilt, or timestamp fields.
public struct StrokePoint: Hashable, Codable, Sendable {
  
  /// Position in view coordinates at the time of capture.
  public var position: CGPoint

  /// Scalar speed (points per second) at this point.
  /// Useful for velocity-sensitive brush rendering (faster → thinner).
  public var speed: CGFloat

  /// Which finger produced this point (0-based, ordered by first contact).
  public var touchOrder: Int

  /// Force Touch pressure at this point in the stroke.
  /// Range is 0.0 (no pressure) to 1.0 (maximum pressure).
  /// Useful for pressure-sensitive brush rendering (harder → thicker/darker).
  public var pressure: CGFloat
  
  public init(
    position: CGPoint,
    speed: CGFloat,
    touchOrder: Int,
    pressure: CGFloat = 0
  ) {
    self.position = position
    self.speed = speed
    self.touchOrder = touchOrder
    self.pressure = pressure
  }
}

extension StrokePoint {
  public static func at(x: CGFloat, y: CGFloat) -> Self {
    self.init(
      position: CGPoint(x: x, y: y),
      speed: 1,
      touchOrder: 0,
      pressure: 0
    )
  }
}
