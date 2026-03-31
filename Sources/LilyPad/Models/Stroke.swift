//
//  Stroke.swift
//  InteractionKit
//
//  Created by Dave Coleman on 28/3/2026.
//

import Foundation

public struct Stroke: Hashable, Codable, Sendable, Identifiable {
  public let id: UUID
  public var points: [CGPoint]

  public init(points: [CGPoint]) {
    self.id = UUID()
    self.points = points
  }
}

extension Stroke {
  public var rawPoints: [CGPoint] { points }

  public func sampledPoints(every stride: Int) -> [CGPoint] {
    rawPoints.sampled(every: stride)
  }
}
