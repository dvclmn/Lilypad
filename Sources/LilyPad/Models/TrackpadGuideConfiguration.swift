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

  public init(
    inset: CGFloat = 8,
    rounding: CGFloat = 12,
    strokeWidth: CGFloat = 2,
    strokeColor: Color = Color.gray.opacity(0.15)
  ) {
    self.inset = inset
    self.rounding = rounding
    self.strokeWidth = strokeWidth
    self.strokeColor = strokeColor
  }
}
