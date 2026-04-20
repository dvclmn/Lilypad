//
//  Model+TouchPoint.swift
//  Lilypad
//
//  Created by Dave Coleman on 5/5/2025.
//

import CoreGraphics
import Foundation
//import InteractionKit
import BasePrimitives

/// A single trackpad touch with position, velocity, and stable ordering.
///
/// Each `TouchPoint` represents one finger on the trackpad for a single frame.
/// The `touchOrder` property provides stable finger numbering based on the order
/// fingers were placed down — finger 1 stays finger 1 for the duration of contact.
///
/// Positions are provided in the coordinate space requested when configuring
/// the touch modifier (normalized 0–1, or mapped to a view size).
public struct TouchPoint: Identifiable, Hashable, Sendable {

  /// Stable identity derived from `NSTouch.identity`, consistent across
  /// the full lifecycle of a single finger contact (began → moved → ended).
  public let id: TouchID

  /// Stable ordering index (0-based) assigned when this finger first touched
  /// down. Finger ordering is determined by arrival time — the first finger
  /// to touch gets order 0, the second gets order 1, etc. This remains
  /// constant for the lifetime of the touch, even if earlier fingers lift off.
  public let touchOrder: Int

  /// Position in the configured coordinate space.
  public var position: CGPoint

  /// Smoothed velocity in points per second (or normalised units/s).
  public let velocity: CGVector

  /// Scalar speed — the magnitude of `velocity`.
  public let magnitude: CGFloat

  /// Force Touch pressure as reported by the trackpad hardware.
  /// Range is 0.0 (no pressure) to 1.0 (maximum pressure).
  /// This is an ambient value — the trackpad reports a single pressure
  /// for the whole surface, so all active touches share the same reading.
  public let pressure: CGFloat

  /// Force Touch stage: 0 = not pressing, 1 = normal click,
  /// 2 = deep (force) click. Ambient, same as `pressure`.
  public let stage: Int

  /// Current phase of this touch in its lifecycle.
  public let phase: InteractionPhase

  /// Whether this finger is stationary on the trackpad (resting, not moving).
  /// Seems like an overlap with `phase`, but choosing to keep
  /// as AppKit NSTouch has them separate
  public let isResting: Bool

  public init(
    id: TouchID,
    touchOrder: Int,
    position: CGPoint,
    velocity: CGVector,
    magnitude: CGFloat,
    pressure: CGFloat = 0,
    stage: Int = 0,
    phase: InteractionPhase,
    isResting: Bool = false,
  ) {
    self.id = id
    self.touchOrder = touchOrder
    self.position = position
    self.velocity = velocity
    self.magnitude = magnitude
    self.pressure = pressure
    self.stage = stage
    self.phase = phase
    self.isResting = isResting
  }
}

extension TouchPoint {
  public func withPosition(_ position: CGPoint) -> Self {
    var result = self
    result.position = position
    return result
  }
}
