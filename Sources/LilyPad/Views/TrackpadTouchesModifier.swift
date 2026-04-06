//
//  TouchesViewModifier.swift
//  LilyPad
//
//  Created by Dave Coleman on 7/5/2025.
//

import BasePrimitives
import InteractionKit
import SwiftUI

/// View modifier that overlays trackpad touch capture on any view.
///
/// Enable `showIndicators` for a visual debug overlay showing numbered
/// finger positions on the trackpad.
struct TrackpadTouchesModifier: ViewModifier {
  @State private var touchesForIndicators: [TouchPoint] = []

  let canvasSize: Size<CanvasSpace>
  let mapping: TouchMapping
  let trackpadMode: TrackpadMode
  let trackpadMatchesZoom: Bool
  let guideVisibility: TrackpadGuideVisibility
  let showsTouchIndicators: Bool
  let action: TouchesUpdate

  func body(content: Content) -> some View {
    content
      .overlay {

        /// NSView that detects touches
        if effectiveTrackpadMode.isEnabled {
          TrackpadTouchesView { handleTouches($0) }
        }

        /// Finger location indicators, if enabled
        if effectiveTrackpadMode.isEnabled, showsTouchIndicators {
          TouchIndicatorsView(touches: touchesForIndicators)
        }

        if guideVisibility.shouldShowGuide(for: trackpadMode), let guideRect {
          TrackpadGuideView(mappedRect: guideRect)
        }

      }  // END overlay

      .modifier(TrackpadModeModifier(mode: effectiveTrackpadMode))
  }
}

extension TrackpadTouchesModifier {

  private var guideRect: TrackpadMappedRect? {
    .makeRect(
      in: canvasSize,
      mapping: mapping,
      sourceAspectRatio: CGSize.trackpadAspectRatio,
    )
  }

  private func handleTouches(_ touches: [TouchPoint]) {
    let mapped = mapping.mapTouches(touches, in: canvasSize)
    action(mapped)

    if showsTouchIndicators {
      self.touchesForIndicators = mapped
    }
  }
  private var effectiveTrackpadMode: TrackpadMode {
    //    .inactive
    isPreview ? .active : trackpadMode
  }

}

extension View {

  /// Captures trackpad multi-touch input and delivers ordered touch updates.
  ///
  /// - Parameters:
  ///   - isEnabled: Whether touch capture is active. Default `true`.
  ///   - showIndicators: Show a debug overlay with numbered finger positions.
  ///     Default `true`.
  ///   - action: Called each time touches change, with an array of
  ///     ``TouchPoint`` values sorted by first-contact order.
  public func trackpadTouches(
    canvasSize: CGSize,
    mapping: TouchMapping = .fit,
    mode: TrackpadMode = .inactive,
    trackpadMatchesZoom: Bool,
    guideVisibility: TrackpadGuideVisibility = .always,
    showsTouchIndicators: Bool = true,
    perform action: @escaping TouchesUpdate,
  ) -> some View {
    self.modifier(
      TrackpadTouchesModifier(
        canvasSize: .init(fromCGSize: canvasSize),
        mapping: mapping,
        trackpadMode: mode,
        trackpadMatchesZoom: trackpadMatchesZoom,
        guideVisibility: guideVisibility,
        showsTouchIndicators: showsTouchIndicators,
        action: action,
      )
    )
  }
}
