//
//  TrackpadGuideDimmingView.swift
//  Lilypad
//
//  Created by Dave Coleman on 13/11/2026.
//

import SwiftUI

struct TrackpadGuideDimmingView: View {

  let dimming: CGFloat
  let mappedRect: CGRect
  let outline: RoundedRectangle
  let inset: CGFloat
  let ignoredEdges: Edge.Set

  var body: some View {

    if dimming > 0 {
      GeometryReader { geometry in
        let origin = geometry.frame(in: .named(TrackpadGuideView.CoordinateSpace.viewport)).origin

        // The fill can start outside the viewport. Keep the opening aligned
        // with the border by translating it into the fill's coordinates.
        let opening =
          mappedRect
          .insetBy(dx: inset, dy: inset)
          .offsetBy(dx: -origin.x, dy: -origin.y)

        Canvas { context, size in
          var path = Path(CGRect(origin: .zero, size: size))
          if !opening.isEmpty {
            path.addPath(outline.path(in: opening))
          }
          // The even-odd rule leaves the rounded opening transparent.
          context.fill(
            path,
            with: .color(.black.opacity(Double(dimming))),
            style: FillStyle(eoFill: true),
          )
        }
        .clipped()
      }
      .ignoresSafeArea(.container, edges: ignoredEdges)
    }

  }
}
