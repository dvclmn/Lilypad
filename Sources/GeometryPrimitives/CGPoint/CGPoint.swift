//
//  CGPoint.swift
//  InteractionKit
//
//  Created by Dave Coleman on 30/3/2026.
//

import SwiftUI

extension CGSize {
  package var midpoint: CGPoint {
    return CGPoint(x: width / 2, y: height / 2)
  }
  
  public func isNearUnitPoint(
    _ unitPoint: UnitPoint,
    in size: CGSize,
    threshold: CGFloat = 10,
  ) -> Bool {
    let targetPoint = unitPoint.toCGPoint(in: size)
    return self.distance(to: targetPoint) <= threshold
  }
  
  public func distance(to other: CGPoint) -> CGFloat {
    let dx = CGFloat(x - other.x)
    let dy = CGFloat(y - other.y)
    return sqrt((dx * dx) + (dy * dy))
  }
  
  public func debugColour(
    unitPoint: UnitPoint,
    in size: CGSize
  ) -> Color {
    guard self.isNearUnitPoint(unitPoint, in: size) else {
      return Color.clear
    }
    return unitPoint.debugColour
  }
}
