//
//  TrackpadEnvironment.swift
//  Lilypad
//
//  Created by Dave Coleman on 8/11/2026.
//

import SwiftUI

extension EnvironmentValues {
  /// When Lilypad displays the trackpad mapping guide.
  @Entry public var trackpadGuideVisibility: TrackpadGuideVisibility = .always

  /// Whether Lilypad displays numbered touch indicators when capture is active.
  /// Indicators are hidden for normalised mapping, whose positions are not points.
  @Entry public var showsTrackpadTouchIndicators: Bool = true
}

extension View {
  /// Sets guide visibility for trackpad capture surfaces in this view hierarchy.
  ///
  /// Apply after `.trackpadTouches(...)` or to an ancestor of the capture view.
  public func trackpadGuideVisibility(_ visibility: TrackpadGuideVisibility) -> some View {
    environment(\.trackpadGuideVisibility, visibility)
  }

  /// Sets whether trackpad capture surfaces display numbered touch indicators.
  ///
  /// Apply after `.trackpadTouches(...)` or to an ancestor of the capture view.
  /// This setting changes presentation only; touch callbacks are unaffected.
  public func trackpadTouchIndicators(_ isVisible: Bool) -> some View {
    environment(\.showsTrackpadTouchIndicators, isVisible)
  }
}
