//
//  CGPoint+Sample.swift
//  Lilypad
//
//  Created by Dave Coleman on 31/3/2026.
//

import Foundation

extension Array where Element == CGPoint {

  /// Returns every `stride`-th point, always including the first and last.
  ///
  /// Useful for reducing point density before rendering or storage.
  public func sampled(every stride: Int) -> [CGPoint] {
    guard stride > 1, count > 1 else { return self }

    var result: [CGPoint] = []
    result.reserveCapacity(count / stride + 1)

    var i = 0
    while i < count {
      result.append(self[i])
      i += stride
    }

    if let last, result.last != last {
      result.append(last)
    }

    return result
  }
}

@inlinable func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
  CGPoint(
    x: lhs.x - rhs.x,
    y: lhs.y - rhs.y,
  )
}

@inlinable public func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
  precondition(!rhs.isZero, "Cannot divide by zero")
  return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
}
