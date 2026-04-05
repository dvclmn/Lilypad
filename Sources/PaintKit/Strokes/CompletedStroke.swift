//
//  CompletedStroke.swift
//  InteractionKit
//
//  Created by Dave Coleman on 3/4/2026.
//

import Foundation
import LilyPad

/// A finished stroke — the finger has lifted and the points are final.
public struct Stroke: Hashable, Codable, Sendable, Identifiable, StrokeData {
  public let id: UUID

  /// Which finger drew this stroke (for colour assignment, etc.).
  public let touchOrder: Int
  
  /// The points that make up this stroke, in capture order.
  public let points: [StrokePoint]
  
  public let style: BrushStyle
  
  public init(
    id: UUID = .init(),
    touchOrder: Int,
    points: [StrokePoint],
    style: BrushStyle = .default
  ) {
    self.id = id
    self.touchOrder = touchOrder
    self.points = points
    self.style = style
  }
}
