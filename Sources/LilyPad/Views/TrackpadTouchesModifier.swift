//
//  TouchesViewModifier.swift
//  Lilypad
//
//  Created by Dave Coleman on 7/5/2025.
//

import SwiftUI

/// View modifier that overlays trackpad touch capture on any view.
///
/// Presentation comes from Lilypad's environment values. Geometry is either
/// supplied by the caller or read directly inside the overlay, without copying
/// it into state or publishing it through the environment.
struct TrackpadTouchesModifier: ViewModifier {
  @State private var touchesForIndicators: [TouchID: TouchPoint] = [:]
  @Environment(\.trackpadGuideVisibility) private var guideVisibility
  @Environment(\.showsTrackpadTouchIndicators) private var showsTouchIndicators

  /// `nil` measures the modified view. A supplied size skips measurement.
  let viewportSize: CGSize?
  let mapping: TouchMapping
  let trackpadMode: TrackpadMode
  let action: ([TouchPoint], TrackpadMappedRect) -> Void

  func body(content: Content) -> some View {
    content
      .overlay {
        if let viewportSize {
          captureOverlay(in: viewportSize)
        } else {
          // Keep this reader inside the overlay so it cannot determine the
          // base view's size. Its size is consumed directly, with no state hop.
          GeometryReader { geometry in
            captureOverlay(in: geometry.size)
          }
        }
      }

      /// Modifier to handle pointer hiding etc for Trackpad mode
      .modifier(TrackpadModeModifier(mode: trackpadMode))
  }
}

extension TrackpadTouchesModifier {
  @ViewBuilder
  private func captureOverlay(in size: CGSize) -> some View {
    // Reject transient zero sizes and invalid geometry. Capture starts as soon
    // as layout supplies valid bounds; no timer or loading state is required.
    if let mappedRect = context.mappedSize(in: size) {
      ZStack {
        if trackpadMode.isEnabled {
          TrackpadTouchesView {
            handleTouches($0, mappedRect: mappedRect)
          }
          .onDisappear {
            // A removed capture view cannot deliver its remaining terminal events.
            touchesForIndicators.removeAll()
          }
        }

        if showsIndicators {
          TouchIndicatorsView(
            touches: touchesForIndicators.values.sorted {
              $0.touchOrder < $1.touchOrder
            }
          )
        }

        if guideVisibility.shouldShowGuide(for: trackpadMode) {
          TrackpadGuideView(mappedRect: mappedRect)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  private var showsIndicators: Bool {
    showsTouchIndicators && mapping != .normalised && trackpadMode.isEnabled
  }

  private var context: TrackpadMappingContext {
    .init(guide: guideVisibility, mode: trackpadMode, mapping: mapping)
  }

  private func handleTouches(
    _ touches: [TouchPoint],
    mappedRect: TrackpadMappedRect,
  ) {
    let mapped = mapping.mapTouches(
      touches,
      in: mappedRect,
    )
    // Consumers need every phase, including ended and cancelled contacts.
    action(mapped, mappedRect)

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
