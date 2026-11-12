//
//  TrackpadGuideView.swift
//  Lilypad
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

/// Displays the bounds of the exact mapping used for input, including its offset.
/// Place in the destination coordinate space. Visibility does not affect capture.
public struct TrackpadGuideView: View {

  private enum CoordinateSpace {
    case viewport
  }

  @Environment(\.showsTrackpadGuide) private var isVisible

  let dimmingIgnoringSafeAreaEdges: Edge.Set
  public let mapping: TrackpadMapping
  let configuration: TrackpadGuideConfiguration

  public init(
    dimmingIgnoringSafeAreaEdges: Edge.Set = [],
    mapping: TrackpadMapping,
    configuration: TrackpadGuideConfiguration,
  ) {
    self.dimmingIgnoringSafeAreaEdges = dimmingIgnoringSafeAreaEdges
    self.mapping = mapping
    self.configuration = configuration
  }

  public var body: some View {
    if isVisible {
      let outline = RoundedRectangle(cornerRadius: configuration.rounding)
      let dimming = min(1, max(0, configuration.dimming))

      outline
        .strokeBorder(
          // TODO: Hard-coded colour for now, consider moving to config
          Color.gray.opacity(0.15),
          //          configuration.strokeColor,
          lineWidth: configuration.strokeWidth,
        )
        .padding(configuration.inset)
        .frame(
          width: mapping.mappedRect.width,
          height: mapping.mappedRect.height,
        )
        .position(
          x: mapping.mappedRect.midX,
          y: mapping.mappedRect.midY,
        )
        .background {
          if dimming > 0 {
            GeometryReader { geometry in
              let origin = geometry.frame(in: .named(CoordinateSpace.viewport)).origin
              let inset = configuration.inset
              // The fill can start outside the viewport. Keep the opening aligned
              // with the border by translating it into the fill's coordinates.
              let opening = mapping.mappedRect.insetBy(dx: inset, dy: inset)
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
            .ignoresSafeArea(.container, edges: dimmingIgnoringSafeAreaEdges)
          }
        }
        .coordinateSpace(.named(CoordinateSpace.viewport))
        .allowsHitTesting(false)
    }
  }
}
