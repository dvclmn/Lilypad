//
//  TouchesViewModifier.swift
//  Lilypad
//
//  Created by Dave Coleman on 7/5/2025.
//

import SwiftUI

/// View modifier that overlays trackpad touch capture on any view.
///
/// Enable `showIndicators` for a visual debug overlay showing
/// numbered finger positions on the trackpad.
struct TrackpadTouchesModifier: ViewModifier {
  @State private var touchesForIndicators: [TouchID: TouchPoint] = [:]

  let canvasSize: CGSize
  let viewportRect: CGRect?
  let zoomLevel: Double
  let zoomRange: ClosedRange<Double>
  let mapping: TouchMapping
  let trackpadMode: TrackpadMode
  let guideVisibility: TrackpadGuideVisibility
  let showsTouchIndicators: Bool
  let viewportRectWaitDuration: TimeInterval
  let action: ([TouchPoint], TrackpadMappedRect) -> Void

  func body(content: Content) -> some View {
    content
      .overlay {

        RectLoadingView(
          viewportRect: viewportRect,
          waitDuration: viewportRectWaitDuration,
        ) { viewportRect in
          /// NSView that detects touches
          if trackpadMode.isEnabled {
            TrackpadTouchesView {
              handleTouches($0, viewportRect: viewportRect)
            }
            .onDisappear {
              // A removed capture view cannot deliver its remaining terminal events.
              touchesForIndicators.removeAll()
            }
          }

          /// Finger location indicators, if enabled
          if showsIndicators {
            TouchIndicatorsView(
              touches: touchesForIndicators.values.sorted {
                $0.touchOrder < $1.touchOrder
              }
            )
          }

          TrackpadGuideView(context: context, viewportRect: viewportRect)
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
    guard let mappedSize = context.mappedSize(in: viewportRect.size) else { return }
    let mapped = mapping.mapTouches(
      touches,
      in: mappedSize,
    )
    // Consumers need every phase, including ended and cancelled contacts.
    action(mapped, mappedSize)

    // Indicator state spans updates: a partial event must not erase other fingers.
    for touch in mapped {
      switch touch.phase {
        case .ended, .cancelled:
          touchesForIndicators.removeValue(forKey: touch.id)

        case .began, .moved, .stationary:
          touchesForIndicators[touch.id] = touch

        default:
          break
      }
    }
  }
}
