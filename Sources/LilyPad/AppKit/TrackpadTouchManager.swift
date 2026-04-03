//
//  TrackpadTouchManager.swift
//  LilyPad
//
//  Created by Dave Coleman on 3/5/2025.
//

import AppKit
import InteractionKit

/// Processes raw `NSTouch` events into ordered `TouchPoint` values with
/// smoothed velocity and stable finger numbering.
///
/// Maintains per-touch history so that velocity can be smoothed across frames,
/// and so that each finger receives a consistent `touchOrder` based on when
/// it first made contact.
///
/// ## Coordinate Spaces
///
/// - ``CoordinateSpace/normalized``: Raw 0–1 values from `NSTouch`.
///   Origin is bottom-left of the trackpad.
/// - ``CoordinateSpace/view(_:)``: Normalised values scaled to a view size,
///   with Y flipped so origin is top-left (matching SwiftUI convention).
///
class TrackpadTouchManager {

  /// Controls how aggressively velocity is smoothed. Lower values produce
  /// smoother (more laggy) output; higher values track raw input more closely.
  /// Range: 0 (frozen) to 1 (no smoothing). Default `0.3`.
  var smoothingFactor: CGFloat = 0.3

  enum CoordinateSpace {
    case normalized
    case view(CGSize)
  }

  /// Per-touch bookkeeping, keyed by touch identity hash.
  private var history: [TouchID: TouchState] = [:]

  /// Processes a set of raw `NSTouch` values from a single event into an
  /// ordered array of ``TouchPoint`` values.
  ///
  /// The returned array is sorted by the order each finger first made contact
  /// (earliest first), providing stable finger numbering across frames.
  func processTouches(
    _ nsTouches: Set<NSTouch>,
    timestamp: TimeInterval,
    in space: CoordinateSpace,
  ) -> [TouchPoint] {

    var results: [TouchPoint] = []
    results.reserveCapacity(nsTouches.count)

    for touch in nsTouches {
      let id = TouchID(rawValue: touch.identity.hash)
      let position = position(for: touch, in: space)

      /// Calculate smoothed velocity from history
      var velocity = CGVector.zero
      if let previous = history[id] {
        let dt = CGFloat(timestamp - previous.lastTimestamp)
        if dt > 0 {
          velocity = CGVector.smoothed(
            previous: previous.smoothedVelocity,
            prevPosition: previous.lastPosition,
            currentPosition: position,
            factor: smoothingFactor,
            dt: dt,
          )
        }
      }

      /// Determine the first-seen time for ordering
      let firstSeen: TimeInterval
      if let existing = history[id] {
        firstSeen = existing.firstSeen
      } else {
        firstSeen = timestamp
      }

      /// Update or clean up history
      if touch.phase == .ended || touch.phase == .cancelled {
        history.removeValue(forKey: id)

      } else {
        history[id] = TouchState(
          lastPosition: position,
          lastTimestamp: timestamp,
          smoothedVelocity: velocity,
          firstSeen: firstSeen,
        )
      }

      let magnitude = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)

      results.append(
        TouchPoint(
          id: id,
          touchOrder: 0,  // placeholder — assigned after sorting
          position: position,
          velocity: velocity,
          magnitude: magnitude,
          phase: InteractionPhase(from: touch.phase),
          isResting: touch.isResting,
        ))
    }

    /// Sort by first-seen time (earliest first), then assign stable order indices
    results.sort { lhs, rhs in
      let lhsTime = history[lhs.id]?.firstSeen ?? timestamp
      let rhsTime = history[rhs.id]?.firstSeen ?? timestamp
      return lhsTime < rhsTime
    }

    return results.enumerated().map { index, point in
      TouchPoint(
        id: point.id,
        touchOrder: index,
        position: point.position,
        velocity: point.velocity,
        magnitude: point.magnitude,
        phase: point.phase,
        isResting: point.isResting,
      )
    }
  }

  private func position(
    for touch: NSTouch,
    in space: CoordinateSpace,
  ) -> CGPoint {
    let normalised = touch.normalizedPosition
    return switch space {
      case .normalized:
        normalised
      case .view(let size):
        CGPoint(
          x: size.width * normalised.x,
          y: size.height * (1 - normalised.y),
        )
    }
  }
}
