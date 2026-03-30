//
//  UnitPoint+Offset.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 30/7/2025.
//

import SwiftUI

extension UnitPoint {

  /// Returns an offset based on this UnitPoint's position.
  /// Positive `dx`/`dy` will push away from edges, negative will pull inward.
  public func offset(dx: CGFloat, dy: CGFloat) -> CGSize {
    CGSize(
      width: Self.directionMultiplier(for: x) * dx,
      height: Self.directionMultiplier(for: y) * dy,
    )
  }

  public func offset(by amount: CGFloat) -> CGSize {
    offset(dx: amount, dy: amount)
  }

  public func offset(by size: CGSize, mapping: AxisMapping = .default) -> CGSize {
    offset(
      dx: size.value(along: .horizontal, mapping: mapping),
      dy: size.value(along: .vertical, mapping: mapping),
    )
  }

  private static func directionMultiplier(for coordinate: CGFloat) -> CGFloat {
    coordinate < 0.5 ? +1 : coordinate > 0.5 ? -1 : 0
  }

  public func distanceSquared(to b: UnitPoint) -> CGFloat {
    let dx = x - b.x
    let dy = y - b.y
    return dx * dx + dy * dy
  }

}
