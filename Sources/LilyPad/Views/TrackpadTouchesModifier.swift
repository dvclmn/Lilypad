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
          AreaOutlineShape(colour: .mint, rounding: 4, lineWidth: 1)
            .frame(width: guideRect.size.width, height: guideRect.size.height)
            .allowsHitTesting(false)
          //          .areaOutline(
          //            colour: .mint,
          //            rounding: 6,
          //            lineWidth: 1
          //          )

          //          TrackpadGuideView(mappedRect: guideRect)
        }

      }  // END overlay

      /// Modifier to handle pointer hiding etc for Trackpad mode
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
