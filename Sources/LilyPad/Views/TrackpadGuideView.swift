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
      RoundedRectangle(cornerRadius: configuration.rounding)
        .fill(.clear)
        .stroke(
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
        .allowsHitTesting(false)
    }
  }
}
