//
//  TouchMapping.swift
//  InteractionKit
//
//  Created by Dave Coleman on 4/4/2026.
//

import Foundation
import InteractionKit

public enum TouchMapping: String, Equatable, Codable, Sendable {
  /// Default — guarantees all touches fit within View
  case fit

  case fill

  /// Raw 0-1, no scaling
  case normalised
}

/// Note: magnitude is recomputed from the transformed velocity
/// to match `Touch​Point`’s semantics.
/// `magnitude` represents the magnitude of `velocity`.
extension TouchMapping {

  func mapTouches(
    _ touches: [TouchPoint],
    in viewSize: Size<CanvasSpace>,
    sourceAspectRatio: CGFloat = CGSize.trackpadAspectRatio,
  ) -> [TouchPoint] {
    
    /// Guard against invalid sizes
    guard viewSize.width > 0, viewSize.height > 0 else { return touches }

    switch self {
      case .normalised:
        /// Raw 0–1 space; caller can map as needed.
        return touches

      case .fit, .fill:
        /// Uniformly scale from a unit-width rectangle with height = sourceAspectRatio into the view, with optional letterboxing/cropping.
        let sourceWidth: CGFloat = 1.0
        let sourceHeight: CGFloat = sourceAspectRatio

        let scale: CGFloat
        switch self {
          case .fit:
            scale = min(viewSize.width / sourceWidth, viewSize.height / sourceHeight)

          case .fill:
            scale = max(viewSize.width / sourceWidth, viewSize.height / sourceHeight)

          default:
            scale = 1  // unreachable
        }

        /// Center the scaled source rect within the view; offsets may be negative for `.fill` (cropping).
        let scaledWidth = sourceWidth * scale
        let scaledHeight = sourceHeight * scale
        let offsetX = 0.0
//        let offsetX = (viewSize.width - scaledWidth) / 2
        let offsetY = (viewSize.height - scaledHeight) / 2

        return touches.map { point in
          /// Positions are provided in normalised space with origin at bottom-left.
          /// Map from normalised [0,1] into source rect (unit width, height = sourceAspectRatio)
          let nx = point.position.x
          let ny = point.position.y
          let xSource = nx * sourceWidth
          let ySource = ny * sourceHeight
          let mappedPosition = CGPoint(
            x: offsetX + xSource * scale,
            y: offsetY + (sourceHeight - ySource) * scale,  // flip Y to top-left origin
          )

          /// Velocity should follow the same transform: scale X by `scale`, Y by `sourceHeight * scale`, and flip Y.
          let mappedVelocity = CGVector(
            dx: point.velocity.dx * scale,
            dy: -point.velocity.dy * sourceHeight * scale,
          )

          /// Scalar speed should be derived from the transformed velocity vector.
          let mappedMagnitude = hypot(mappedVelocity.dx, mappedVelocity.dy)

          return TouchPoint(
            id: point.id,
            touchOrder: point.touchOrder,
            position: mappedPosition,
            velocity: mappedVelocity,
            magnitude: mappedMagnitude,
            pressure: point.pressure,
            stage: point.stage,
            phase: point.phase,
            isResting: point.isResting,
          )
        }
    }
  }
}
