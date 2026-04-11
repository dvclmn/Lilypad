//
//  TouchesViewModifier.swift
//  LilyPad
//
//  Created by Dave Coleman on 7/5/2025.
//

//import BasePrimitives
@_spi(Internals) import BasePrimitives
import InteractionKit
import SwiftUI

/// View modifier that overlays trackpad touch capture on any view.
///
/// Enable `showIndicators` for a visual debug overlay showing numbered
/// finger positions on the trackpad.
struct TrackpadTouchesModifier: ViewModifier {
  @Environment(\.viewportRect) private var viewportRect
  @State private var touchesForIndicators: [TouchPoint] = []

  let canvasSize: CGSize
//  let canvasSize: Size<CanvasSpace>
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

        if guideVisibility.shouldShowGuide(for: trackpadMode), let trackpadMappedSize {
          AreaOutlineShape(colour: .mint, rounding: 4, lineWidth: 1)
            .frame(
              width: trackpadMappedSize.rect.size.width,
              height: trackpadMappedSize.rect.size.height,
            )

        }

      }  // END overlay

      /// Modifier to handle pointer hiding etc for Trackpad mode
      .modifier(TrackpadModeModifier(mode: effectiveTrackpadMode))

  }
}

extension TrackpadTouchesModifier {

  private var trackpadMappedSize: TrackpadMappedRect? {
    guard let viewSize = viewportRect?.size else { return nil }

    //  private var trackpadMappedSize: Size<ScreenSpace>? {
    //    guard let viewSize = viewportRect?.size else {
    //      return nil
    //    }
    //    let viewSize = viewportRect?.size
    //    let viewSize: Size<ScreenSpace>

    //    if let viewportSize = viewportRect?.size {
    //      viewSize = .init(fromCGSize: viewportSize)
    //    } else {
    //      viewSize = .init(width: canvasSize.width, height: canvasSize.height)
    //    }
    return TrackpadMappedRect.makeRect(
      in: viewSize,
//      in: .init(fromCGSize: viewSize),
      //      in: viewSize,
      mapping: mapping,
      sourceAspectRatio: CGSize.trackpadAspectRatio,
    )
  }

  private func handleTouches(_ touches: [TouchPoint]) {
    guard let trackpadMappedSize else { return }
    //    let mapped = mapping.mapTouches(touches, in: trackpadMappedSize)
    let mapped = mapping.mapTouches(
      touches,
      in: trackpadMappedSize,
    )
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
