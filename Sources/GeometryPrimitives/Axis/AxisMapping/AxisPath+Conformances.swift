//
//  Adjustable+Conformances.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 6/1/2026.
//

import SwiftUI

extension CGSize: AxisKeyPathWritable {
  public static var primaryWritableKey: WritableKeyPath<Self, CGFloat> { \.width }
  public static var secondaryWritableKey: WritableKeyPath<Self, CGFloat> { \.height }
}

extension CGRect: AxisKeyPathWritable {
  public static var primaryWritableKey: WritableKeyPath<Self, CGFloat> { \.size.width }
  public static var secondaryWritableKey: WritableKeyPath<Self, CGFloat> { \.size.height }
}

extension CGPoint: AxisKeyPathWritable {
  public static var primaryWritableKey: WritableKeyPath<Self, CGFloat> { \.x }
  public static var secondaryWritableKey: WritableKeyPath<Self, CGFloat> { \.y }
}
extension CGVector: AxisKeyPathWritable {
  public static var primaryWritableKey: WritableKeyPath<Self, CGFloat> { \.dx }
  public static var secondaryWritableKey: WritableKeyPath<Self, CGFloat> { \.dy }
}

extension UnitPoint: AxisKeyPathWritable {
  public static var primaryWritableKey: WritableKeyPath<Self, CGFloat> { \.x }
  public static var secondaryWritableKey: WritableKeyPath<Self, CGFloat> { \.y }
}

extension EdgeInsets: AxisKeyPathWritable {
  public static var primaryWritableKey: WritableKeyPath<Self, CGFloat> { \.horizontalUniform }
  public static var secondaryWritableKey: WritableKeyPath<Self, CGFloat> { \.verticalUniform }
}

//extension GeometryAxis: AxisKeyPathReadable {
//  public static var primaryKey: KeyPath<Self, Void> { \Self.Cases.horizontal }
//  public static var secondaryKey: KeyPath<Self, Void> { \Self.Cases.vertical }
//}

//extension CGSize: AxisCompatible {
//  public var naturalComponents: (primary: CGFloat, secondary: CGFloat) { (width, height) }
//  public static func create(primary: CGFloat, secondary: CGFloat) -> Self {
//    CGSize(width: primary, height: secondary)
//  }
//}
//
//extension GridPosition: AxisCompatible {
//  public var naturalComponents: (primary: Int, secondary: Int) { (column, row) }
//  public static func create(primary: Int, secondary: Int) -> Self {
//    GridPosition(row: secondary, column: primary)
//  }
//}
//
//extension EdgeInsets: AxisCompatible {
//  /// We define the natural components as the Lead/Trail (H) and Top/Bottom (V)
//  public var naturalComponents: (primary: CGFloat, secondary: CGFloat) {
//    /// Using single edges as the "representative" values
//    (leading, top)
//  }
//
//  public static func create(primary: CGFloat, secondary: CGFloat) -> Self {
//    /// primary = horizontal (leading/trailing), secondary = vertical (top/bottom)
//    EdgeInsets(top: secondary, leading: primary, bottom: secondary, trailing: primary)
//  }
//}

//extension AxisAddressable where Component: BinaryFloatingPoint {
//  /// A helper for when you want to create a new instance from H/V values
//  public static func make(
//    h: Component,
//    v: Component,
//    mapping: AxisMapping = .identity
//  ) -> Self {
//    /// Create a dummy instance and then use unified 'setting' logic
//    /// This ensures the mapping is applied consistently.
//    return Self.zero
//      .setting(h, along: .horizontal, mapping: mapping)
//      .setting(v, along: .vertical, mapping: mapping)
//  }
//}
//
//// MARK: - Conformances
//
//extension CGSize: AxisAddressable {
//  public var identityComponent: CGFloat {
//    get { width }
//    set { width = newValue }
//  }
//  public var transposedComponent: CGFloat {
//    get { height }
//    set { height = newValue }
//  }
//}
//
//extension CGRect: AxisAddressable {
//  public var identityComponent: CGFloat {
//    get { size.width }
//    set { size.width = newValue }
//  }
//  public var transposedComponent: CGFloat {
//    get { size.height }
//    set { size.height = newValue }
//  }
//}
//
//extension CGPoint: AxisAddressable {
//  public var identityComponent: CGFloat {
//    get { x }
//    set { x = newValue }
//  }
//  public var transposedComponent: CGFloat {
//    get { y }
//    set { y = newValue }
//  }
//}
//
//extension UnitPoint: AxisAddressable {
//  public var identityComponent: CGFloat {
//    get { x }
//    set { x = newValue }
//  }
//  public var transposedComponent: CGFloat {
//    get { y }
//    set { y = newValue }
//  }
//}
//
//extension GridPosition: AxisAddressable {
//  public var identityComponent: Int {
//    get { column }
//    set { column = newValue }
//  }
//  public var transposedComponent: Int {
//    get { row }
//    set { row = newValue }
//  }
//}
//
//extension UnitSize: AxisAddressable {
//  public var identityComponent: UnitLength {
//    get { columns }
//    set { columns = newValue }
//  }
//  public var transposedComponent: UnitLength {
//    get { rows }
//    set { rows = newValue }
//  }
//}
//
//extension EdgeInsets: AxisAddressable {
//  public typealias Component = CGFloat
//
//  /// Treat the "Primary/Identity" storage as the Lead/Trail pair
//  public var identityComponent: CGFloat {
//    get { leading + trailing }
//    set {
//      /// When setting a total, distribute it evenly.
//      /// Note: Consider preserving the existing ratio
//      let half = newValue / 2
//      leading = half
//      trailing = half
//    }
//  }
//
//  /// Treat the "Secondary/Transposed" storage as the Top/Bottom pair
//  public var transposedComponent: CGFloat {
//    get { top + bottom }
//    set {
//      let half = newValue / 2
//      top = half
//      bottom = half
//    }
//  }
//}

// MARK: - Addressable
//extension CGSize: AxisAddressable {
//
//  public func value(
//    along axis: Axis2D,
//    convention: AxisConvention
//  ) -> CGFloat {
//    switch axis {
//      case .horizontal: convention.horizontalLength(size: self)
//      case .vertical: convention.verticalLength(size: self)
//    }
//  }
//
//  public func setting(
//    _ newValue: CGFloat,
//    along axis: Axis2D,
//    convention: AxisConvention
//  ) -> Self {
//
//    switch axis {
//      case .horizontal:
//        /// Keep the current vertical, update horizontal
//        return convention.makeCGSize(
//          h: newValue,
//          v: convention.verticalLength(size: self)
//        )
//      case .vertical:
//        /// Keep the current horizontal, update vertical
//        return convention.makeCGSize(
//          h: convention.horizontalLength(size: self),
//          v: newValue
//        )
//    }
//  }
//}
//
//// MARK: - CGPoint
//extension CGPoint: AxisAddressable {
//
//  public func value(
//    along axis: Axis2D,
//    convention: AxisConvention
//  ) -> CGFloat {
//    switch axis {
//      case .horizontal: convention.horizontalValue(for: self)
//      case .vertical: convention.verticalValue(for: self)
//    }
//  }
//
//  public func setting(
//    _ newValue: CGFloat,
//    along axis: Axis2D,
//    convention: AxisConvention
//  ) -> Self {
//    switch axis {
//      case .horizontal:
//        /// Keep the current vertical, update horizontal
//        return convention.makeCGPoint(
//          h: newValue,
//          v: convention.verticalValue(for: self)
//        )
//      case .vertical:
//        /// Keep the current horizontal, update vertical
//        return convention.makeCGPoint(
//          h: convention.horizontalValue(for: self),
//          v: newValue
//        )
//    }
//  }
//}
//
//
//// MARK: - UnitPoint
//extension UnitPoint: AxisAddressable {
//
//  public func value(
//    along axis: Axis2D,
//    convention: AxisConvention
//  ) -> CGFloat {
//    switch axis {
//      case .horizontal: convention.horizontalValue(for: self)
//      case .vertical: convention.verticalValue(for: self)
//    }
//  }
//
//  public func setting(
//    _ newValue: CGFloat,
//    along axis: Axis2D,
//    convention: AxisConvention
//  ) -> Self {
//    switch axis {
//      case .horizontal:
//        /// Keep the current vertical, update horizontal
//        return convention.makeUnitPoint(
//          h: newValue,
//          v: convention.verticalValue(for: self)
//        )
//      case .vertical:
//        /// Keep the current horizontal, update vertical
//        return convention.makeUnitPoint(
//          h: convention.horizontalValue(for: self),
//          v: newValue
//        )
//    }
//  }
//}
//
//
//// MARK: - GridPosition
//extension GridPosition: GridAxisAddressable {
//
//  public func value(along axis: Axis2D, convention: GridAxisConvention) -> Int {
//    switch axis {
//      case .horizontal: return convention.horizontalValue(for: self)
//      case .vertical: return convention.verticalValue(for: self)
//    }
//  }
//
//  public func setting(
//    _ newValue: Int,
//    along axis: Axis2D,
//    convention: GridAxisConvention
//  ) -> Self {
//    switch axis {
//      case .horizontal:
//        return convention.makeGridPosition(
//          h: newValue,
//          v: convention.verticalValue(for: self)
//        )
//      case .vertical:
//        return convention.makeGridPosition(
//          h: convention.horizontalValue(for: self),
//          v: newValue
//        )
//    }
//  }
//
//}
//
//extension UnitSize: GridAxisAddressable {
//
//  public func value(along axis: Axis2D, convention: GridAxisConvention) -> GridLength {
//    switch axis {
//      case .horizontal: return convention.horizontalLength(gridSize: self)
//      case .vertical: return convention.verticalLength(gridSize: self)
//    }
//  }
//
//  public func setting(
//    _ newValue: GridLength,
//    along axis: Axis2D,
//    convention: GridAxisConvention
//  ) -> Self {
//    switch axis {
//      case .horizontal:
//        return convention.makeUnitSize(
//          h: newValue,
//          v: convention.verticalLength(gridSize: self)
//        )
//      case .vertical:
//        return convention.makeUnitSize(
//          h: convention.horizontalLength(gridSize: self),
//          v: newValue
//        )
//    }
//  }
//}
