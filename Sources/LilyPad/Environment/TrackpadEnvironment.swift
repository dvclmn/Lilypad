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
  @Entry public var trackpadGuideConfiguration: TrackpadGuideConfiguration = .init()

  /// Whether explicit `TouchIndicatorsView` instances display mapped touches.
  @Entry public var showsTrackpadTouchIndicators: Bool = true
}

extension View {
  /// Sets guide visibility for trackpad presentation views in this view hierarchy.
  ///
  /// Apply to an ancestor of `TrackpadGuideView` or `TouchIndicatorsView`.
  public func trackpadGuideVisibility(_ isVisible: Bool) -> some View {
    environment(\.showsTrackpadGuide, isVisible)
  }

  /// Sets whether trackpad presentation views display numbered touch indicators.
  ///
  /// Apply to an ancestor of `TrackpadGuideView` or `TouchIndicatorsView`.
  /// This setting changes presentation only; touch callbacks are unaffected.
  public func trackpadTouchIndicators(_ isVisible: Bool) -> some View {
    environment(\.showsTrackpadTouchIndicators, isVisible)
  }
}
