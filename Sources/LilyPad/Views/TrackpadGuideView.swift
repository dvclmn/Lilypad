//
//  TrackpadGuideView.swift
//  Lilypad
//
//  Created by Dave Coleman on 6/4/2026.
//

@_spi(Internals) import BasePrimitives
import SwiftUI

/// Renders a rectangle showing exactly where trackpad touches
/// will be mapped within the view.
///
/// The rectangle preserves the trackpad's physical aspect ratio (~16:10),
/// fitted within the canvas size, so users can see the active touch region.
struct TrackpadGuideView: View {
  @Environment(\.viewportRect) private var viewportRect

  let context: TrackpadMappingContext

  var body: some View {
    if let mappedSize {
      AreaOutlineShape(
        colour: .mint,
        rounding: 4,
        lineWidth: 1,
      )
      .frame(
        width: mappedSize.rect.size.width,
        height: mappedSize.rect.size.height,
      )
    }
  }
}

extension TrackpadGuideView {
  private var mappedSize: TrackpadMappedRect? {
    guard context.guide.shouldShowGuide(for: context.mode),
      let viewportRect,
      let mappedSize = context.mappedSize(in: viewportRect)
    else { return nil }
    return mappedSize
  }
}
