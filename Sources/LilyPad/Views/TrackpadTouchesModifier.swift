//
//  TouchesViewModifier.swift
//  Lilypad
//
//  Created by Dave Coleman on 7/5/2025.
//

@_spi(Internals) import BasePrimitives
import SwiftUI

/// View modifier that overlays trackpad touch capture on any view.
///
/// Enable `showIndicators` for a visual debug overlay showing
/// numbered finger positions on the trackpad.
struct TrackpadTouchesModifier: ViewModifier {
  @Environment(\.viewportRect) private var viewportRect
  @State private var touchesForIndicators: [TouchPoint] = []

  let canvasSize: CGSize
  let mapping: TouchMapping
  let trackpadMode: TrackpadMode
  let guideVisibility: TrackpadGuideVisibility
  let showsTouchIndicators: Bool
  let action: ([TouchPoint], TrackpadMappedRect) -> Void

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

        if let viewportRect {
          TrackpadGuideView(context: <#T##TrackpadMappingContext#>)
        } else {
          StateView("No Viewport Rect found in Environment", icon: .emoji("⚠️"))
        }

      }  // END overlay

      /// Modifier to handle pointer hiding etc for Trackpad mode
      .modifier(TrackpadModeModifier(mode: effectiveTrackpadMode))

    //      .viewportRectIndicator()
  }
}

extension TrackpadTouchesModifier {
  private var context: TrackpadMappingContext {
    .init(guide: guideVisibility, mode: trackpadMode, mapping: mapping)
  }

  private func handleTouches(_ touches: [TouchPoint]) {
    guard let viewportRect,
      let mappedSize = context.mappedSize(in: viewportRect)
    else { return }
    let mapped = mapping.mapTouches(
      touches,
      in: mappedSize,
    )
    action(mapped, mappedSize)

    if showsTouchIndicators {
      self.touchesForIndicators = mapped
    }
  }
  private var effectiveTrackpadMode: TrackpadMode {
    //    .inactive
    isPreview ? .active : trackpadMode
  }

}
