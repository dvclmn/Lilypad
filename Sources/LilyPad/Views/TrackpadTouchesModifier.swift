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
  @State private var touchesForIndicators: [TouchPoint] = []

  let canvasSize: CGSize
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

        ViewportRectLoadingView(waitDuration: viewportRectWaitDuration) { viewportRect in
          /// NSView that detects touches
          if trackpadMode.isEnabled {
            TrackpadTouchesView {
              handleTouches($0, viewportRect: viewportRect)
            }
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
}

private struct ViewportRectLoadingView<ResolvedContent: View>: View {
  @Environment(\.viewportRect) private var viewportRect
  @State private var hasFinishedWaiting: Bool = false

  let waitDuration: TimeInterval
  let resolvedContent: (CGRect) -> ResolvedContent

  init(
    waitDuration: TimeInterval,
    @ViewBuilder resolvedContent: @escaping (CGRect) -> ResolvedContent,
  ) {
    self.waitDuration = waitDuration
    self.resolvedContent = resolvedContent
  }

  var body: some View {
    ZStack {
      if hasFinishedWaiting {
        if let viewportRect {
          resolvedContent(viewportRect)
            .transition(.opacity)
        } else {
          fallbackMessage
            .transition(.opacity)
        }
      } else {
        ProgressView("Loading...")
          .transition(.opacity)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: hasFinishedWaiting)
    .animation(.easeInOut(duration: 0.2), value: viewportRect != nil)
    .task(id: clampedWaitDuration) {
      hasFinishedWaiting = false

      guard clampedWaitDuration > 0 else {
        hasFinishedWaiting = true
        return
      }

      try? await Task.sleep(for: .seconds(clampedWaitDuration))

      guard !Task.isCancelled else { return }
      withAnimation(.easeInOut(duration: 0.2)) {
        hasFinishedWaiting = true
      }
    }
  }

  private var clampedWaitDuration: TimeInterval {
    guard waitDuration.isFinite else { return 0 }
    return max(0, waitDuration)
  }

  private var fallbackMessage: some View {
    Text("Lilypad is still waiting for a `viewportRect` value in the Environment.")
      .font(.callout)
      .foregroundStyle(.secondary)
  }
}
