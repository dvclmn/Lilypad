//
//  Unit+CGSize.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 27/2/2026.
//

import Foundation

extension CGSize {

  /// The axis is required here, as we're working with two dimensional
  /// `CGSize`, so need to address a specific dimension, based on
  /// the appropriate convention via `AxisMapping`
  public func toGridCount(
    along axis: GridAxis,
    using unitSize: CGSize,
    mapping: AxisMapping = .default,
    rounding: GridRounding = .down
  ) -> Int? {
    /// Ensures the same convention is used for extracting both length values
    let lengthOfSelf = self.value(along: axis, mapping: mapping)
    let unitLength = unitSize.value(along: axis, mapping: mapping)
    return lengthOfSelf.toGridCount(using: unitLength, rounding: rounding)
  }


}

//extension Optional where Wrapped == CGSize {
//  public func gridLength(
//    _ count: Int,
//    along axis: GridAxis,
//  ) -> CGFloat? {
//    return count.toScreenLength(along: axis, using: self)
//  }
//}
