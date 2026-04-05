//
//  TouchesViewModifier.swift
//  LilyPad
//
//  Created by Dave Coleman on 7/5/2025.
//

import InteractionKit
import SwiftUI

/// View modifier that overlays trackpad touch capture on any view.
///
/// Enable `showIndicators` for a visual debug overlay showing numbered
/// finger positions on the trackpad.
struct TrackpadTouchesModifier: ViewModifier {
  @Environment(\.artworkFrameInViewport) private var artworkFrame
  @Environment(\.zoomClamped) private var zoomClamped
  @State private var touchesForIndicators: [TouchPoint] = []

  let canvasSize: Size<CanvasSpace>
  let mode: TrackpadMode
  let mapping: TouchMapping
  let showsIndicators: Bool
  let action: TouchesUpdate

  func body(content: Content) -> some View {
    //    GeometryReader { proxy in
    content
      .overlay {
        if mode.isEnabled {
          TrackpadTouchesView(isActive: mode.isEnabled) { touches in

            let mapped = mapping.mapTouches(touches, in: canvasSize)
            action(mapped)

            if showsIndicators {
              self.touchesForIndicators = mapped
            }
          }
        }

        if mode.isEnabled, showsIndicators {
          TouchIndicatorsView(touches: touchesForIndicators)
        }

      }  // END overlay

      //    } // END geo reader

      .modifier(TrackpadModeModifier(mode: mode))
  }
}

extension TrackpadTouchesModifier {
  private var coordinateSpaceMapper: CoordinateSpaceMapper? {
    guard let artworkFrame else { return nil }
    return .init(artworkFrame: artworkFrame, zoomClamped: zoomClamped)
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
    mapping: TouchMapping = .fit,
    showsIndicators: Bool = true,
    perform action: @escaping TouchesUpdate,
  ) -> some View {
    self.modifier(
      TrackpadTouchesModifier(
        canvasSize: .init(fromCGSize: canvasSize),
        mode: mode,
        mapping: mapping,
        showsIndicators: showsIndicators,
        action: action,
      )
    )
  }
}
