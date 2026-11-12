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

  @Environment(\.showsTrackpadGuide) private var isVisible
  public let mapping: TrackpadMapping
  let configuration: TrackpadGuideConfiguration

  public init(
    mapping: TrackpadMapping,
    configuration: TrackpadGuideConfiguration
  ) {
    self.mapping = mapping
    self.configuration = configuration
  }

  public var body: some View {
    if isVisible {
      let outline = RoundedRectangle(cornerRadius: configuration.rounding)
      let dimming = min(1, max(0, configuration.dimming))

      outline
        .strokeBorder(
          configuration.strokeColor,
          lineWidth: configuration.strokeWidth,
        )
        .padding(configuration.inset)
        .frame(
          width: mapping.mappedRect.width,
          height: mapping.mappedRect.height,
        )
        .position(
          x: mapping.mappedRect.midX,
          y: mapping.mappedRect.midY
        )
        .background {
          if dimming > 0 {
            Canvas { context, size in
              let bounds = CGRect(origin: .zero, size: size)
              let inset = configuration.inset
              let opening = mapping.mappedRect.insetBy(dx: inset, dy: inset)
              var path = Path(bounds)
              if !opening.isEmpty {
                path.addPath(outline.path(in: opening))
              }
              // The even-odd rule leaves the rounded opening transparent.
              context.fill(
                path,
                with: .color(.black.opacity(Double(dimming))),
                style: FillStyle(eoFill: true)
              )
            }
            .clipped()
          }
        }
        .allowsHitTesting(false)
    }
  }
}
