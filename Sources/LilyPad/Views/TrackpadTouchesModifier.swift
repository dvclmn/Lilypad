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
        if effectiveTrackpadMode.isEnabled {
          TrackpadTouchesView(isActive: effectiveTrackpadMode.isEnabled) { touches in

            let mapped = mapping.mapTouches(touches, in: canvasSize)
            action(mapped)

            if showsTouchIndicators {
              self.touchesForIndicators = mapped
            }
          }
        }

        if effectiveTrackpadMode.isEnabled, showsTouchIndicators {
          TouchIndicatorsView(touches: touchesForIndicators)
        }

        let rect = TrackpadMappedRect.makeRect(
          in: canvasSize,
          mapping: mapping,
          sourceAspectRatio: CGSize.trackpadAspectRatio,
        )

        if effectiveTrackpadMode.isEnabled, showsGuide, let rect {
          TrackpadGuideView(mappedRect: rect)
        }

      }  // END overlay

      .modifier(TrackpadModeModifier(mode: effectiveTrackpadMode))
  }
}

extension TrackpadTouchesModifier {
  private var effectiveTrackpadMode: TrackpadMode {
    .inactive
    //    isPreview ? .active : trackpadMode
  }

  private var showsGuide: Bool {
    switch guideVisibility {
      case .always: true
      case .drawingMode: effectiveTrackpadMode.isEnabled ? true : false
      case .never: false
    }
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
    mode: TrackpadMode = .inactive,
    trackpadMatchesZoom: Bool,
    mapping: TouchMapping = .fit,
    showsIndicators: Bool = true,
    guideVisibility: TrackpadGuideVisibility = .always,
    perform action: @escaping TouchesUpdate,
  ) -> some View {
    self.modifier(
      TrackpadTouchesModifier(
        canvasSize: .init(fromCGSize: canvasSize),
        trackpadMode: mode,
        trackpadMatchesZoom: trackpadMatchesZoom,
        mapping: mapping,
        showsIndicators: showsIndicators,
        guideVisibility: guideVisibility,
        action: action,
      )
    )
  }
}
