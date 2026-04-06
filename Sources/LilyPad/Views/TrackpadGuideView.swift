//
//  TrackpadGuideView.swift
//  LilyPad
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

  let mappedRect: TrackpadMappedRect

  var body: some View {
    Rectangle()
      .strokeBorder(
        Color.mint.opacity(0.3),
        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
      )
      .frame(width: mappedRect.size.width, height: mappedRect.size.height)
//      .position(
//        x: mappedRect.origin.x + mappedRect.size.width / 2,
//        y: mappedRect.origin.y + mappedRect.size.height / 2
//      )
      .allowsHitTesting(false)
  }
}
