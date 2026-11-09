//
//  TrackpadEnvironment.swift
//  Lilypad
//
//  Created by Dave Coleman on 8/11/2026.
//

import SwiftUI

extension EnvironmentValues {
  /// Whether Lilypad displays the trackpad mapping guide, independently of capture.
  @Entry public var showsTrackpadGuide: Bool = true

  /// Whether Lilypad displays numbered touch indicators when capture is active.
  /// Indicators are hidden for normalised mapping, whose positions are not points.
  @Entry public var showsTrackpadTouchIndicators: Bool = true
}

extension View {
  /// Sets guide visibility for trackpad capture surfaces in this view hierarchy.
  ///
  /// Apply after `.trackpadTouches(...)` or to an ancestor of the capture view.
  public func trackpadGuideVisibility(_ isVisible: Bool) -> some View {
    environment(\.showsTrackpadGuide, isVisible)
  }

  /// Sets whether trackpad capture surfaces display numbered touch indicators.
  ///
  /// Apply after `.trackpadTouches(...)` or to an ancestor of the capture view.
  /// This setting changes presentation only; touch callbacks are unaffected.
  public func trackpadTouchIndicators(_ isVisible: Bool) -> some View {
    environment(\.showsTrackpadTouchIndicators, isVisible)
  }
}
