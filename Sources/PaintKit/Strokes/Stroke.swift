//
//  Stroke.swift
//  LilyPad
//
//  Created by Dave Coleman on 28/3/2026.
//

//import Foundation

/// A recorded sequence of points from a single continuous finger contact.
///
/// Points are stored in whatever coordinate space was configured at capture
/// time. For resolution-independent storage, capture in normalised space
/// and scale to the target view size at render time.
//public struct Stroke: Hashable, Codable, Sendable, Identifiable {
//  public let id: UUID
//  public var points: [CGPoint]
//
//  public init(points: [CGPoint] = []) {
//    self.id = UUID()
//    self.points = points
//  }
//
//  /// Returns a reduced copy keeping every `stride`-th point.
//  public func sampled(every stride: Int) -> [CGPoint] {
//    points.sampled(every: stride)
//  }
//}
