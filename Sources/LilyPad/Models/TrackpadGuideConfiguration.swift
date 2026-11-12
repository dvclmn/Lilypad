//
//  TrackpadGuideConfiguration.swift
//  Lilypad
//
//  Created by Dave Coleman on 11/11/2026.
//

import SwiftUI

public struct TrackpadGuideConfiguration: Codable, Sendable {
  let inset: CGFloat
  let rounding: CGFloat
  let strokeWidth: CGFloat
//  let strokeColor: Color
  let dimming: CGFloat
  let dimmingSafeAreaEdges: Edge.Set

  /// - Parameters:
  ///   - dimming: The opacity of the black fill outside the guide, clamped to `0...1`.
  ///   - dimmingSafeAreaEdges: Container edges where the fill extends into the safe area.
  public init(
    inset: CGFloat = 8,
    rounding: CGFloat = 12,
    strokeWidth: CGFloat = 2,
//    strokeColor: Color = Color.gray.opacity(0.15),
    dimming: CGFloat = 0,
    dimmingSafeAreaEdges: Edge.Set = []
  ) {
    self.inset = inset
    self.rounding = rounding
    self.strokeWidth = strokeWidth
//    self.strokeColor = strokeColor
    self.dimming = dimming
    self.dimmingSafeAreaEdges = dimmingSafeAreaEdges
  }
}
