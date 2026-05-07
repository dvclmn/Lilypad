//
//  RectLoadingView.swift
//  Lilypad
//
//  Created by Dave Coleman on 7/5/2026.
//

import BasePrimitives
import SwiftUI

struct RectLoadingView<ResolvedContent: View>: View {
  @Environment(\.viewportRect) private var viewportRect
  @State private var hasFinishedWaiting: Bool = false

  let waitDuration: TimeInterval
  let resolvedContent: (CGRect) -> ResolvedContent

  let animation: Animation = Styles.animationExtraQuickNSmooth

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
      }
//      else {
//        ProgressView("Loading...")
//          .transition(.opacity)
//      }
    }
    .animation(animation, value: hasFinishedWaiting)
    .animation(animation, value: viewportRect != nil)
    
    .task(id: clampedWaitDuration) {
      hasFinishedWaiting = false

      guard clampedWaitDuration > 0 else {
        hasFinishedWaiting = true
        return
      }

      try? await Task.sleep(for: .seconds(clampedWaitDuration))

      guard !Task.isCancelled else { return }
      //      withAnimation(animation) {
      hasFinishedWaiting = true
      //      }
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
