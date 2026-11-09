//
//  TrackpadTouchSample.swift
//  Lilypad
//
//  Created by Dave Coleman on 10/11/2026.
//

import AppKit

/// A snapshot keeps AppKit event extraction separate from contact bookkeeping.
/// It also allows lifecycle and velocity regressions to use ordinary values.
struct TrackpadTouchSample {
  let identity: any NSObjectProtocol
  let position: CGPoint
  let phase: NSTouch.Phase
  var isResting: Bool = false
  var deviceSize: CGSize? = nil
}
