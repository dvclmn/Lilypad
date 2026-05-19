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
/// fitted within the canvas size, so users can see the active touch region.
struct TrackpadGuideView: View {
//  @Environment(\.viewportRect) private var viewportRect
  
  let context: TrackpadMappingContext
  let viewportRect: CGRect

  /// Note: previously had these respond to zoom, but the trackpad guide
  /// doesn't scale with zoom, so this is not neccesary.
  private let rounding: Double = 4
  private let lineWidth: Double = 1

  var body: some View {
    if let mappedSize {
      RoundedRectangle(cornerRadius: rounding)
        .fill(.clear)
        .stroke(
          Color.mint.opacity(0.15),
          lineWidth: lineWidth,
        )
        .frame(
          width: mappedSize.rect.size.width,
          height: mappedSize.rect.size.height,
        )
        .allowsHitTesting(false)

    }
  }
}

extension TrackpadGuideView {

  private var mappedSize: TrackpadMappedRect? {
    guard context.guide.shouldShowGuide(for: context.mode),
//      let viewportRect,
      let mappedSize = context.mappedSize(in: viewportRect)
    else { return nil }
    return mappedSize
  }
}
