//
//  Model+TouchPoint.swift
//  Lilypad
//
//  Created by Dave Coleman on 5/5/2025.
//

import CoreGraphics
import AppKit

/// A single trackpad touch with position, velocity, and stable ordering.
///
/// Each `TouchPoint` represents one finger on the trackpad for a single frame.
/// The `touchOrder` property provides stable finger numbering based on the order
/// fingers were placed down — finger 1 stays finger 1 for the duration of contact.
///
/// Positions always use normalised trackpad coordinates: (0, 0) is bottom-left,
/// X increases rightwards and Y increases upwards. Both axes range from 0 to 1.
/// Mapping produces a separate `MappedTouchPoint`; it never changes this sample.
public struct TouchPoint: Identifiable, Sendable {

  /// Opaque identity issued by the capture handler, consistent across
  /// the full lifecycle of a single finger contact (began → moved → ended).
  public let id: TouchID

  /// Stable ordering index (0-based) assigned when this finger first touched
  /// down. Finger ordering is determined by arrival time — the first finger
  /// to touch gets order 0, the second gets order 1, etc. This remains
  /// constant for the lifetime of the touch, even if earlier fingers lift off.
  /// Numbering restarts at zero after all contacts end. Simultaneous arrivals
  /// are ordered spatially; order is not an index into the current update array.
  public let touchOrder: Int

  /// Normalised position, bottom-left origin, X rightwards and Y upwards.
  public let position: CGPoint

  /// Smoothed velocity in normalised axis units per second, with the same
  /// directions as `position`. This is not physical speed: the two axes may
  /// represent different physical distances.
  public let velocity: CGVector

  /// Scalar speed — the magnitude of `velocity`.
  public var magnitude: CGFloat { hypot(velocity.dx, velocity.dy) }

  /// Source surface dimensions reported by AppKit in device points (72 ppi),
  /// not screen pixels or destination view points. Nil means unavailable or
  /// invalid; no hardware proportions are assumed. Retained per contact when
  /// a later sample omits geometry.
  public let deviceSize: CGSize?

  /// Force Touch pressure as reported by the trackpad hardware.
  /// Range is 0.0 (no pressure) to 1.0 (maximum pressure).
  /// This is an ambient value — the trackpad reports a single pressure
  /// for the whole surface, so all active touches share the same reading.
  public let pressure: CGFloat

  /// Force Touch stage: 0 = not pressing, 1 = normal click,
  /// 2 = deep (force) click. Ambient, same as `pressure`.
  public let stage: Int

  /// Current phase of this touch in its lifecycle.
  public let phase: NSTouch.Phase

  /// Whether the driver classifies this contact as resting. This is distinct
  /// from a stationary phase; a resting contact is not necessarily motionless.
  public let isResting: Bool

  /// Creates a normalised sample. Position must be finite and within 0...1
  /// on both axes; velocity must be finite. Invalid device geometry becomes nil.
  /// Mapping output belongs in `MappedTouchPoint`, never in this initializer.
  public init(
    id: TouchID,
    touchOrder: Int,
    position: CGPoint,
    velocity: CGVector,
    deviceSize: CGSize? = nil,
    pressure: CGFloat = 0,
    stage: Int = 0,
    phase: NSTouch.Phase,
    isResting: Bool = false,
  ) {
    precondition(position.x.isFinite && position.y.isFinite
      && (0...1).contains(position.x) && (0...1).contains(position.y),
      "TouchPoint requires a normalised position in 0...1")
    precondition(velocity.dx.isFinite && velocity.dy.isFinite,
      "TouchPoint requires finite normalised velocity")
    self.id = id
    self.touchOrder = touchOrder
    self.position = position
    self.velocity = velocity
    self.deviceSize = validatedTouchDeviceSize(deviceSize)
    self.pressure = pressure
    self.stage = stage
    self.phase = phase
    self.isResting = isResting
  }
}
