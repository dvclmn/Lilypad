//
//  MappedTouchPoint.swift
//  Lilypad
//
//  Created by Dave Coleman on 10/11/2026.
//

import AppKit

/// A touch expressed in a destination coordinate space chosen by the caller.
///
/// Distinct from `TouchPoint`, whose coordinates always remain normalised.
/// `source` retains the original sample and all contact metadata. The consumer
/// must track which destination space a mapped value belongs to.
public struct MappedTouchPoint: Identifiable, Sendable {
  public let source: TouchPoint
  public let position: CGPoint
  public let velocity: CGVector
  public var magnitude: CGFloat { hypot(velocity.dx, velocity.dy) }

  public var id: TouchID { source.id }
  public var touchOrder: Int { source.touchOrder }
  public var pressure: CGFloat { source.pressure }
  public var stage: Int { source.stage }
  public var phase: NSTouch.Phase { source.phase }
  public var isResting: Bool { source.isResting }

  init(source: TouchPoint, position: CGPoint, velocity: CGVector) {
    self.source = source
    self.position = position
    self.velocity = velocity
  }

  /// Converts into another coordinate space, transforming position and velocity
  /// together. The transform must contain finite coefficients and produce finite
  /// results. Speed is derived from the resulting vector, never copied unchanged.
  ///
  /// This is finger velocity expressed in the new space, not a derivative of a
  /// moving coordinate system. A changing pan/zoom does not add apparent motion.
  public func transformed(by transform: CGAffineTransform) -> Self {
    Self(
      source: source,
      position: position.applying(transform),
      velocity: CGVector(
        dx: transform.a * velocity.dx + transform.c * velocity.dy,
        dy: transform.b * velocity.dx + transform.d * velocity.dy
      )
    )
  }
}
