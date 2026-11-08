//
//  TrackpadTouches+ViewExt.swift
//  InteractionKit
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

extension View {

  /// Captures ordered trackpad touch updates mapped into this view's bounds.
  ///
  /// Lilypad reads the modified view's size inside an overlay. No canvas size,
  /// zoom state or ancestor viewport environment is required. The overlay does
  /// not determine the modified view's layout; apply this to a sized surface.
  ///
  /// With `.fit` or `.fill`, positions use local view coordinates with a top-left
  /// origin. With `.normalised`, positions remain in 0–1 trackpad coordinates
  /// with a bottom-left origin, and velocity remains in those units per second.
  /// The returned rectangle always describes the mapping in local view points.
  ///
  /// Use `.trackpadGuideVisibility(_:)` and `.trackpadTouchIndicators(_:)` after
  /// this modifier, or on an ancestor, to configure presentation.
  ///
  /// - Parameters:
  ///   - mapping: Fits the trackpad's aspect ratio within the view, fills the view
  ///     with cropping, or delivers untransformed normalised touches.
  ///   - mode: Whether capture is enabled and whether the pointer is hidden.
  ///     Defaults to `.inactive`.
  ///   - action: Receives each touch update in first-contact order and the mapped
  ///     rectangle. Updates include ended and cancelled touches, and may contain
  ///     only a subset of the fingers currently touching the trackpad.
  public func trackpadTouches(
    isEnabled: Bool = true,
    mapping: TouchMapping = .fit,
    perform action: @escaping ([TouchPoint], TrackpadMappedRect) -> Void,
  ) -> some View {
    modifier(
      TrackpadTouchesModifier(
        isEnabled: isEnabled,
        viewportSize: nil,
        mapping: mapping,
        action: action,
      )
    )
  }

  /// Captures trackpad touches using a viewport size already owned by the caller.
  ///
  /// This overload performs no geometry measurement. Use it when a parent already
  /// measures the same capture surface and shares its size with several tools.
  /// Supply the surface's untransformed local size in points, rather than an
  /// artwork size, a global frame or another view's safe-area size.
  ///
  /// Positions and the mapped rectangle use a local zero origin; `.normalised`
  /// leaves touch coordinates unchanged. Geometry updates take effect without an
  /// artificial delay. Zero, negative or non-finite sizes suspend capture and its
  /// overlays until valid geometry arrives. No fallback size is substituted.
  ///
  /// - Parameters:
  ///   - viewportSize: The current size of the capture surface in local points.
  ///   - mapping: How trackpad coordinates map into the viewport.
  ///   - mode: Whether capture is enabled and whether the pointer is hidden.
  ///   - action: Receives ordered touch updates and the local mapping rectangle.
  public func trackpadTouches(
    viewportSize: CGSize,
    isEnabled: Bool = true,
    mapping: TouchMapping = .fit,
    perform action: @escaping ([TouchPoint], TrackpadMappedRect) -> Void,
  ) -> some View {
    modifier(
      TrackpadTouchesModifier(
        isEnabled: isEnabled,
        viewportSize: viewportSize,
//        trackpadMode: mode,
        mapping: mapping,
        action: action,
      )
    )
  }

  /// Compatibility overload for existing clients.
  ///
  /// Only `viewportRect.size` is used for geometry. `canvasSize`, `zoomLevel` and
  /// `zoomRange` had no effect on mapping and remain unused. The waiting duration
  /// is now ignored: capture starts as soon as valid geometry is available.
  /// A `nil` viewport suspends capture until the caller supplies a valid rectangle.
  /// The explicit presentation arguments take precedence over inherited settings.
  @available(
    *, deprecated,
    message: "Use trackpadTouches(mapping:mode:perform:) or the viewportSize overload, with trackpadGuideVisibility(_:) and trackpadTouchIndicators(_:)."
  )
  public func trackpadTouches(
    canvasSize: CGSize,
    viewportRect: CGRect?,
    zoomLevel: Double,
    zoomRange: ClosedRange<Double>,
    mapping: TouchMapping = .fit,
    mode: TrackpadMode = .inactive,
    guideVisibility: TrackpadGuideVisibility = .always,
    showsTouchIndicators: Bool = true,
    viewportRectWaitDuration: TimeInterval = 1,
    perform action: @escaping ([TouchPoint], TrackpadMappedRect) -> Void,
  ) -> some View {
    trackpadTouches(
      viewportSize: viewportRect?.size ?? .zero,
      mode: mode,
      mapping: mapping,
      perform: action,
    )
    .trackpadGuideVisibility(guideVisibility)
    .trackpadTouchIndicators(showsTouchIndicators)
  }
}

// MARK: - Presentation

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
