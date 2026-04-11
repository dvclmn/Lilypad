//
//  CGVector+Smoothing.swift
//  LilyPad
//
//  Created by Dave Coleman on 28/3/2026.
//

import Foundation
//import InteractionKit
import BasePrimitives

extension CGVector {

  /// Returns a smoothed velocity using exponential moving average (EMA).
  ///
  /// Blends the previous smoothed velocity with a newly calculated raw velocity
  /// derived from the position delta. Lower `factor` values produce smoother
  /// output with more lag; higher values track raw input more closely.
  ///
  /// - Parameters:
  ///   - smoothed: The previous frame's smoothed velocity.
  ///   - prevPosition: Position at the previous frame.
  ///   - currentPosition: Position at the current frame.
  ///   - factor: Smoothing factor in 0–1. Default `0.3`.
  ///   - deltaTime: Time elapsed since the previous frame, in seconds.
  static func smoothed(
    previous smoothed: CGVector,
    prevPosition: CGPoint,
    currentPosition: CGPoint,
    factor: CGFloat = 0.3,
    dt deltaTime: CGFloat
  ) -> CGVector {
    let raw = velocity(from: prevPosition, to: currentPosition, dt: deltaTime)
    return smoothed.adjustBoth(with: raw) { _, prev, next in
      (prev * (1 - factor)) + (next * factor)
    }
  }

  /// Raw velocity calculated from a position delta over time.
  static func velocity(
    from previous: CGPoint,
    to current: CGPoint,
    dt deltaTime: CGFloat
  ) -> CGVector {
    let delta = (current - previous) / deltaTime
    return CGVector(dx: delta.x, dy: delta.y)
  }
}
