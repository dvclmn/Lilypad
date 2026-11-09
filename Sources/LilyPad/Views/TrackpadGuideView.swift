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

  public init(mapping: TrackpadMapping) { self.mapping = mapping }

  private let rounding: Double = 4
  private let lineWidth: Double = 1

  public var body: some View {
    if isVisible {
      RoundedRectangle(cornerRadius: rounding)
        .fill(.clear)
        .stroke(
          Color.mint.opacity(0.15),
          lineWidth: lineWidth,
        )
        .frame(
          width: mapping.mappedRect.width,
          height: mapping.mappedRect.height,
        )
        .position(x: mapping.mappedRect.midX, y: mapping.mappedRect.midY)
        .allowsHitTesting(false)
    }
  }
}
