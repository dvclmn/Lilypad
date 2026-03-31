//
//  UnitSpan.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 1/10/2025.
//

import SwiftUI

/// Pair of two positions in unit space.
/// Describes a start and end point
public struct UnitSpan: Hashable, Sendable {
  public var start: UnitPoint
  public var end: UnitPoint

  public init(start: UnitPoint, end: UnitPoint) {
    self.start = start
    self.end = end
  }
}

extension UnitSpan {
  public var vector: CGVector {
    CGVector(dx: end.x - start.x, dy: end.y - start.y)
  }
}

extension Axis {

  /// Returns the start and end UnitPoints for a gradient, given how
  /// “primary/secondary storage” maps onto horizontal/vertical.
  public func toGradientSpan(mapping: AxisMapping = .identity) -> UnitSpan {
    mapping.select(
      primary: UnitSpan(start: .leading, end: .trailing),  // “primary is horizontal”
      secondary: UnitSpan(start: .top, end: .bottom),  // “secondary is vertical”
      for: self.toGridAxis,
    )
  }

  //
  //  /// Returns the start and end UnitPoints for a gradient, given a convention relating dimensions to axis.
  //  public func toGradientSpan(mapping: AxisMapping = .identity) -> UnitSpan {
  //    //  public func toGradientSpan(convention: AxisConvention = .widthIsHorizontal) -> UnitSpan {
  //    mapping.select(primary: <#T##T#>, secondary: <#T##T#>, for: self.toGridAxis)
  ////    switch (self, mapping) {
  ////      case (.horizontal, .identity), (.vertical, .heightIsHorizontal):
  ////        return UnitSpan(start: .leading, end: .trailing)
  ////      case (.horizontal, .heightIsHorizontal), (.vertical, .widthIsHorizontal):
  ////        return UnitSpan(start: .top, end: .bottom)
  ////    }
  //  }
}
