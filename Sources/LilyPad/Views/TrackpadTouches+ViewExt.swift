//
//  TrackpadTouches+ViewExt.swift
//  Lilypad
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

extension View {
  /// Captures normalised trackpad touches without measuring a mapping target.
  ///
  /// Positions use a bottom-left origin, X rightwards, Y upwards, and 0...1 on
  /// each axis. Velocity uses those same axis units per second. Capture does
  /// not map, clip, clamp or display input. Use `TrackpadMapping` separately.
  ///
  /// Updates include ended/cancelled contacts and may contain only a subset
  /// of active fingers, in first-contact order. Maintain active contacts by ID.
  /// The receiving view still needs AppKit event routing and useful layout.
  /// Disabling/removing capture ends its session; consumers must clear their
  /// interaction state, as the removed view cannot deliver terminal events.
  public func trackpadTouches(
    isEnabled: Bool = true,
    perform action: @escaping TouchesUpdate
  ) -> some View {
    modifier(TrackpadTouchesModifier(isEnabled: isEnabled, action: action))
  }
}
