//
//  TouchState.swift
//  InteractionKit
//
//  Created by Dave Coleman on 1/4/2026.
//

import Foundation

/// Internal bookkeeping for velocity smoothing between frames.
struct TouchState {
  var lastPosition: CGPoint
  var lastTimestamp: TimeInterval
  var smoothedVelocity: CGVector = .zero
}
