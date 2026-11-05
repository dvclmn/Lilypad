//
//  TrackpadGuideView.swift
//  Lilypad
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

/// Renders a rectangle showing exactly where trackpad touches
/// will be mapped within the view.
///
/// The rectangle preserves the trackpad's physical aspect ratio (~16:10),
/// fitted within the viewport, so users can see the active touch region.
struct TrackpadGuideView: View {
  let mappedRect: TrackpadMappedRect

  private let rounding: Double = 4
  private let lineWidth: Double = 1

  var body: some View {
    RoundedRectangle(cornerRadius: rounding)
      .fill(.clear)
      .stroke(
        Color.mint.opacity(0.15),
        lineWidth: lineWidth,
      )
      .frame(
        width: mappedRect.rect.width,
        height: mappedRect.rect.height,
      )
      .allowsHitTesting(false)
  }
}
