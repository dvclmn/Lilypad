//
//  TrackpadGuideConfiguration.swift
//  Lilypad
//
//  Created by Dave Coleman on 11/11/2026.
//

import SwiftUI

public struct TrackpadGuideConfiguration: Codable, Sendable, Equatable {
  public var inset: CGFloat
  public var rounding: CGFloat
  public var strokeWidth: CGFloat
  public var dimming: CGFloat

  /// - Parameters:
  ///   - dimming: The opacity of the black fill outside the guide, clamped to `0...1`.
  public init(
    inset: CGFloat = 8,
    rounding: CGFloat = 12,
    strokeWidth: CGFloat = 2,
    dimming: CGFloat = 0.2,
  ) {
    self.inset = inset
    self.rounding = rounding
    self.strokeWidth = strokeWidth
    self.dimming = dimming
  }
}
