//
//  TrackpadGuideConfiguration.swift
//  Lilypad
//
//  Created by Dave Coleman on 11/11/2026.
//

import SwiftUI

public struct TrackpadGuideConfiguration {
  let inset: CGFloat
  let rounding: CGFloat
  let strokeWidth: CGFloat
  let strokeColor: Color
  let dimming: CGFloat

  /// - Parameter dimming: The opacity of the black fill outside the guide, clamped to `0...1`.
  public init(
    inset: CGFloat = 8,
    rounding: CGFloat = 12,
    strokeWidth: CGFloat = 2,
    strokeColor: Color = Color.gray.opacity(0.15),
    dimming: CGFloat = 0
  ) {
    self.inset = inset
    self.rounding = rounding
    self.strokeWidth = strokeWidth
    self.strokeColor = strokeColor
    self.dimming = dimming
  }
}
