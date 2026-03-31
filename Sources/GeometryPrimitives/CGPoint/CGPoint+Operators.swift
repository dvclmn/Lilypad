//
//  CGPoint+Operators.swift
//  InteractionKit
//
//  Created by Dave Coleman on 31/3/2026.
//

import Foundation

public func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
  return CGPoint(
    x: lhs.x - rhs.x,
    y: lhs.y - rhs.y,
  )
}

public func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
  precondition(rhs != 0 && rhs != 0, "Cannot divide by zero size")
  return CGPoint(
    x: lhs.x / rhs,
    y: lhs.y / rhs,
  )
}
