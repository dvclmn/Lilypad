//
//  Smoothed.swift
//  InteractionKit
//
//  Created by Dave Coleman on 28/3/2026.
//

import Foundation
import GeometryPrimitives

extension CGVector {

  public static func smoothed(
    previous smoothed: CGVector,
    prevPosition: CGPoint,
    currentPosition: CGPoint,
    factor: CGFloat = 0.2,
    dt deltaTime: CGFloat,
  ) -> Self {
    let raw = CGVector.velocity(
      from: prevPosition,
      to: currentPosition,
      dt: deltaTime,
    )

    //    let dx = (smoothed.dx * (1 - factor)) + (raw.dx * factor)
    //    let dy = (smoothed.dy * (1 - factor)) + (raw.dy * factor)
    //
    //    return CGVector(
    //      dx: dx,
    //      dy: dy,
    //    )
    return smoothed.adjustBoth(with: raw) { _, prev, next in
      (prev * (1 - factor)) + (next * factor)
    }

  }

  /// Raw/simple velocity
  public static func velocity(
    from previous: CGPoint,
    to current: CGPoint,
    dt deltaTime: CGFloat,
  ) -> CGVector {
    let delta = (current - previous) / deltaTime
    return CGVector(dx: delta.x, dy: delta.y)
  }
}
