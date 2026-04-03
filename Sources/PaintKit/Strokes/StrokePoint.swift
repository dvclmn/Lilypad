//
//  StrokePoint.swift
//  LilyPadDemo
//

import Foundation

/// A single point in a stroke, capturing position and dynamics at the moment
/// of capture.
///
/// Richer than a bare `CGPoint` — preserves the speed and finger identity so
/// downstream rendering can vary width, opacity, or colour based on how the
/// user was moving. A future brush engine could extend this with pressure,
/// tilt, or timestamp fields.
public struct StrokePoint: Hashable, Sendable {
  
  /// Position in view coordinates at the time of capture.
  public var position: CGPoint

  /// Scalar speed (points per second) at this point.
  /// Useful for velocity-sensitive brush rendering (faster → thinner).
  public var speed: CGFloat

  /// Which finger produced this point (0-based, ordered by first contact).
  public var touchOrder: Int
}
