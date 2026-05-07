//
//  TouchesViewModifier.swift
//  Lilypad
//
//  Created by Dave Coleman on 7/5/2025.
//

@_spi(Internals) import BasePrimitives
import CoreUtilities
import SwiftUI

/// View modifier that overlays trackpad touch capture on any view.
///
/// Enable `showIndicators` for a visual debug overlay showing
/// numbered finger positions on the trackpad.
struct TrackpadTouchesModifier: ViewModifier {
  @Environment(\.viewportRect) private var viewportRect
  @State private var touchesForIndicators: [TouchPoint] = []

  let canvasSize: CGSize
  let zoomLevel: Double
  let zoomRange: ClosedRange<Double>
  let mapping: TouchMapping
  let trackpadMode: TrackpadMode
  let guideVisibility: TrackpadGuideVisibility
  let showsTouchIndicators: Bool
  let action: ([TouchPoint], TrackpadMappedRect) -> Void

  func body(content: Content) -> some View {
    content
      .overlay {

        if let viewportRect {
          /// NSView that detects touches
          if trackpadMode.isEnabled {
            TrackpadTouchesView { handleTouches($0, viewportRect: viewportRect) }
          }

          /// Finger location indicators, if enabled
          if showsIndicators {
            TouchIndicatorsView(touches: touchesForIndicators)
          }

          TrackpadGuideView(
            context: context,
            zoomLevel: zoomLevel,
            zoomRange: zoomRange,
          )

        } else {
          Text("Lilypad requires that a `viewportRect` value be present in the Environment.")
        }

      }  // END overlay

      /// Modifier to handle pointer hiding etc for Trackpad mode
      .modifier(TrackpadModeModifier(mode: trackpadMode))
  }
}

extension TrackpadTouchesModifier {
  private var showsIndicators: Bool {
    showsTouchIndicators && mapping != .normalised && trackpadMode.isEnabled
  }

  private var context: TrackpadMappingContext {
    .init(guide: guideVisibility, mode: trackpadMode, mapping: mapping)
  }

  private func handleTouches(
    _ touches: [TouchPoint],
    viewportRect: CGRect,
  ) {
    guard let mappedSize = context.mappedSize(in: viewportRect) else { return }
    let mapped = mapping.mapTouches(
      touches,
      in: mappedSize,
    )
    action(mapped, mappedSize)

    if showsTouchIndicators {
      self.touchesForIndicators = mapped
    }
  }
//  private var effectiveTrackpadMode: TrackpadMode {
//    isPreview ? .active(hidesPointer: false) : trackpadMode
//  }

}
