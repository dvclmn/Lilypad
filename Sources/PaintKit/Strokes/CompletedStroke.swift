//
//  CompletedStroke.swift
//  InteractionKit
//
//  Created by Dave Coleman on 3/4/2026.
//

import Foundation
import LilyPad

/// A finished stroke — the finger has lifted and the points are final.
public struct CompletedStroke: Identifiable {
  public let id: UUID = UUID()

  /// The points that make up this stroke, in capture order.
  public let points: [StrokePoint]

  /// Which finger drew this stroke (for colour assignment, etc.).
  public let touchOrder: Int
}
