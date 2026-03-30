//
//  UnitPoint.swift
//  Collection
//
//  Created by Dave Coleman on 30/10/2024.
//

import SwiftUI

/// `UnitPoint` is named after the mathematical concept of the *unit interval*,
/// and more broadly, the unit square/unit space.
///
/// In mathematics, the unit interval is `[0,1]`- the set of all real numbers between
/// `0` and `1`, inclusive. When you extend this to two dimensions, you get the
/// unit square `[0,1] x [0,1]`, and this is what `UnitPoint` represents.
extension UnitPoint: @retroactive Identifiable {
  public var id: String { self.name }
}

extension UnitPoint {

  /// This is just for visual debugging
  public var debugColour: Color {
    switch self {
      case .topLeading: Color.red
      case .top: Color.blue
      case .topTrailing: Color.orange
      case .trailing: Color.brown
      case .bottomTrailing: Color.purple
      case .bottom: Color.mint
      case .bottomLeading: Color.cyan
      case .leading: Color.green
      case .center: Color.yellow
      default: Color.gray
    }
  }

  public var name: String {
    switch self {
      case .topLeading: "Top Leading"
      case .top: "Top"
      case .topTrailing: "Top Trailing"
      case .trailing: "Trailing"
      case .bottomTrailing: "Bottom Trailing"
      case .bottom: "Bottom"
      case .bottomLeading: "Bottom Leading"
      case .leading: "Leading"
      case .center: "Center"
      default:
        "Unknown"
    }
  }

  public static var allKnownCases: [UnitPoint] {
    return [
      .topLeading,
      .top,
      .topTrailing,
      .trailing,
      .bottomTrailing,
      .bottom,
      .bottomLeading,
      .leading,
      .center,
    ]
  }

  /// Returns a rect of given size, positioned inside `container` so that `self` (the alignment point)
  /// corresponds to the same point in the new rect.
  public func positionedRect(size: CGSize, in container: CGRect) -> CGRect {
    let originX = container.origin.x + (container.width - size.width) * self.x
    let originY = container.origin.y + (container.height - size.height) * self.y
    return CGRect(origin: CGPoint(x: originX, y: originY), size: size)
  }

  public func toCGPoint(in size: CGSize) -> CGPoint {
    let result = CGPoint(
      x: self.x * size.width,
      y: self.y * size.height,
    )
    return result
  }

  /// `clamped` if true will trim any values outside of 0...1
  public init(
    point: CGPoint,
    in size: CGSize,
    clamped: Bool = true,
  ) {
    let unitX = size.width.isZero ? 0 : point.x / size.width
    let unitY = size.height.isZero ? 0 : point.y / size.height
    if clamped {
      self.init(x: max(0, min(1, unitX)), y: max(0, min(1, unitY)))
    } else {
      self.init(x: unitX, y: unitY)
    }
  }

  public static func location(
    for point: CGPoint,
    in size: CGSize,
    clamped: Bool = true,
  ) -> UnitPoint {
    UnitPoint(point: point, in: size, clamped: clamped)
  }

  //  public init(fromPoint: CGPoint, in size: CGSize) {
  //    /// Avoid division by zero; if a dimension is zero, fall back to 0
  //    let unitX: CGFloat =
  //      !size.width.isZero
  //      ? fromPoint.x / size.width
  //      : 0
  //
  //    let unitY: CGFloat =
  //      !size.height.isZero
  //      ? fromPoint.y / size.height
  //      : 0
  //
  //    /// Clamp to the unit interval `[0, 1]`
  //    let clampedX = max(0, min(1, unitX))
  //    let clampedY = max(0, min(1, unitY))
  //
  //    self.init(x: clampedX, y: clampedY)
  //  }
  //
  //  public static func location(
  //    for point: CGPoint,
  //    in size: CGSize
  //  ) -> UnitPoint {
  //    let result = UnitPoint(
  //      x: point.x / size.width,
  //      y: point.y / size.height
  //    )
  //    return result
  //  }

}

