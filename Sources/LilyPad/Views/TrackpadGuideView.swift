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

  enum CoordinateSpace {
    case viewport
  }

  @Environment(\.showsTrackpadGuide) private var isVisible

  let dimmingIgnoringSafeAreaEdges: Edge.Set
  let mapping: TrackpadMapping
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
          TrackpadGuideDimmingView(
            dimming: dimming,
            mappedRect: mapping.mappedRect,
            outline: outline,
            inset: configuration.inset,
            ignoredEdges: dimmingIgnoringSafeAreaEdges,
          )
        }
        .coordinateSpace(.named(CoordinateSpace.viewport))
        .allowsHitTesting(false)
    }
  }
}
