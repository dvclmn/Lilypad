//
//  Unit+CGPoint.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 27/2/2026.
//

import SwiftUI

extension CGPoint {
  
  /// Returns the relative UnitPoint (not snapped) within a given size.
  ///
  /// Usage:
  /// ```
  /// let point = CGPoint(x: 10, y: 5)
  /// let frameSize = CGSize(width: 100, height: 100)
  ///
  /// let closestAnchor = point.nearestAnchor(in: frameSize)
  /// print(closestAnchor)  // Might print `.topLeading` if point is near (0,0)
  /// ```
  public func toUnitPoint(
    in size: CGSize,
    rounding: GridRounding = .none,
    fallback: UnitPoint = .center
  ) -> UnitPoint {
    
    guard size.isGreaterThanOrEqualToZero else { return fallback }
    
    let rawX = x / size.width
    let rawY = y / size.height
    
    let valX = rounding.roundedIfNeeded(rawX)
    let valY = rounding.roundedIfNeeded(rawY)

    return UnitPoint(x: valX, y: valY)
  }
}
