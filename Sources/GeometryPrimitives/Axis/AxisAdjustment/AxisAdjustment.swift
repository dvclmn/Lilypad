//
//  AdjustableByAxis.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 15/12/2025.
//

import SwiftUI

/// A convenience protocol for types that expose two scalar components addressable by axis.
///
/// Conforming types (for example `CGPoint` (x/y), `CGSize` (width/height), `UnitPoint`,
/// and `CGVector`) gain ergonomic helpers for reading and writing values along a
/// `GeometryAxis` while honoring an `AxisMapping` (identity vs. transposed).
///
/// Use these APIs when the usual assumptions (x → horizontal, y → vertical) don't always
/// hold. By threading an explicit `AxisMapping`, you can write axis-oriented code that
/// remains correct under rotated/transposed coordinate systems.

// MARK: - Adjustable

/// Cross-value adjustments for `AdjustableByAxis` types.
///
/// These helpers combine two axis-addressable values using a transform. They read
/// corresponding axis components from `self` and `other` and compute a new value.
extension AxisKeyPathWritable {

  /// Combines this value with `other` component-wise using `transform`.
  ///
  /// The same transform is applied on both axes independently.
  public func adjustBoth<Other: AxisKeyPathWritable>(
    with other: Other,
    transform: (_ lhs: Component, _ rhs: Component) -> Component
  ) -> Self where Other.Component == Component {
    return self.adjustBoth(with: other, mapping: .default, transform: transform)
  }

  /// Mapping-aware variant: combines this value with `other` component-wise using `transform`.
  ///
  /// Values for each axis are read using `mapping` and written back honoring `mapping`.
  public func adjustBoth<Other: AxisKeyPathWritable>(
    with other: Other,
    mapping: AxisMapping = .default,
    transform: (_ lhs: Component, _ rhs: Component) -> Component
  ) -> Self where Other.Component == Component {
    var result = self
    for axis in [GeometryAxis.horizontal, .vertical] {
      let lhs = self.value(along: axis, mapping: mapping)
      let rhs = other.value(along: axis, mapping: mapping)
      let newValue = transform(lhs, rhs)
      result = result.setting(newValue, along: axis, mapping: mapping)
    }
    return result
  }

  /// Component-wise combination where the transform also receives the `GeometryAxis` being processed.
  ///
  /// Useful when the horizontal and vertical axes should be treated differently.
  public func adjustBoth<Other: AxisKeyPathWritable>(
    with other: Other,
    transform: (_ axis: GeometryAxis, _ lhs: Component, _ rhs: Component) -> Component
  ) -> Self where Other.Component == Component {
    return self.adjustBoth(with: other, mapping: .default, transform: transform)
  }

  /// Mapping-aware variant: component-wise combination where the transform also receives the `GeometryAxis`.
  public func adjustBoth<Other: AxisKeyPathWritable>(
    with other: Other,
    mapping: AxisMapping = .default,
    transform: (_ axis: GeometryAxis, _ lhs: Component, _ rhs: Component) -> Component
  ) -> Self where Other.Component == Component {
    var result = self
    for axis in [GeometryAxis.horizontal, .vertical] {
      let lhs = self.value(along: axis, mapping: mapping)
      let rhs = other.value(along: axis, mapping: mapping)
      let newValue = transform(axis, lhs, rhs)
      result = result.setting(newValue, along: axis, mapping: mapping)
    }
    return result
  }
}

// MARK: Axis-aware single-axis adjustments

/// Helpers to read/modify a single component along a given `GeometryAxis`, optionally
/// using an `AxisMapping` to resolve which stored component is considered horizontal
/// or vertical for the current context.
extension AxisKeyPathWritable {

  /// Returns a copy with the component along `axis` set to `newValue`.
  ///
  /// The target component is resolved using `mapping`. With `.identity`,
  /// horizontal maps to the type's primary storage (e.g. `width`/`x`), and vertical
  /// to the secondary (e.g. `height`/`y`). With `.transposed`, this relationship is flipped.
  ///
  /// Example:
  /// ```swift
  /// let size = CGSize(width: 10, height: 20)
  /// let wider = size.adjust(.horizontal, newValue: 30) // width: 30, height: 20
  /// let taller = size.adjust(.vertical, newValue: 40)   // width: 10, height: 40
  /// ```
  /// You can pass `mapping: .transposed` to flip which stored field is touched.
  public func adjust(
    _ axis: GeometryAxis,
    newValue: Component,
    mapping: AxisMapping = .default
  ) -> Self {
    setting(newValue, along: axis, mapping: mapping)
  }

  /// Returns a copy by transforming the component along `axis` with `transform`.
  ///
  /// This reads the current value along `axis`, applies `transform`, and writes the
  /// result back using the provided `mapping`.
  ///
  /// Example:
  /// ```swift
  /// let point = CGPoint(x: 5, y: 8)
  /// let shifted = point.adjust(.horizontal) { $0 + 10 } // x: 15, y: 8
  /// ```
  public func adjust(
    _ axis: GeometryAxis,
    mapping: AxisMapping = .default,
    _ transform: (Component) -> Component,
  ) -> Self {
    let current = value(along: axis, mapping: mapping)
    let transformed = transform(current)
    return setting(transformed, along: axis, mapping: mapping)
  }
}

// MARK: Dual-axis numeric adjustments

/// Utilities for applying unary/binary operations to both components of a value whose
/// components are `BinaryFloatingPoint` (e.g. `CGFloat`). These methods make it easy to
/// scale, combine, or otherwise coordinate the horizontal/vertical components together
/// while respecting an optional `AxisMapping`.
extension AxisKeyPathWritable where Component: BinaryFloatingPoint {

  /// Combines this value with `other` by applying `op` component-wise.
  ///
  /// The horizontal components are combined together and the vertical components are
  /// combined together. The components are located using `mapping`.
  ///
  /// Example (component-wise max):
  /// ```swift
  /// let a = CGSize(width: 10, height: 5)
  /// let b = CGSize(width: 8, height: 12)
  /// let c = a.adjustBoth(using: max, with: b) // (10, 12)
  /// ```
  public func adjustBoth(
    using op: (Component, Component) -> Component,
    with other: Self,
    mapping: AxisMapping = .default
  ) -> Self {
    adjustBoth(mapping: mapping) { h, v in
      let otherH = other.value(along: .horizontal, mapping: mapping)
      let otherV = other.value(along: .vertical, mapping: mapping)

      return (
        op(h, otherH),
        op(v, otherV)
      )
    }
  }

  /// Combines both components with a single scalar taken from `other` along `axis`.
  ///
  /// Extracts the specified axis value from `other` (using `mapping`) and applies `op`
  /// to both this value's horizontal and vertical components with that single factor.
  /// Useful for uniform scaling based on one axis.
  ///
  /// Example:
  /// ```swift
  /// let base = CGSize(width: 10, height: 20)
  /// let factors = CGSize(width: 2, height: 3)
  /// // Use the horizontal factor (2) to scale both components
  /// let scaled = base.adjustBoth(using: *, with: factors, along: .horizontal)
  /// // => (20, 40)
  /// ```
  public func adjustBoth(
    using op: (Component, Component) -> Component,
    with other: Self,
    along axis: GeometryAxis,
    mapping: AxisMapping = .default
  ) -> Self {
    let factor = other.value(along: axis, mapping: mapping)

    return adjustBoth(mapping: mapping) { h, v in
      (op(h, factor), op(v, factor))
    }
  }

  /// Applies the same unary `transform` independently to both axes.
  ///
  /// Reads the current horizontal and vertical values, applies `transform` to each,
  /// and writes the results back.
  public func adjustBoth(
    transform: (Component) -> Component
  ) -> Self {
    return adjustBoth(mapping: .default) { h, v in
      (transform(h), transform(v))
    }
  }

  /// Applies the same unary `transform` independently to both axes using the provided mapping.
  ///
  /// This variant makes the mapping explicit. It reads both axis components using `mapping`,
  /// applies `transform` to each value, and writes the results back honoring `mapping`.
  public func adjustBoth(
    mapping: AxisMapping = .default,
    transform: (Component) -> Component
  ) -> Self {
    return adjustBoth(mapping: mapping) { h, v in
      (transform(h), transform(v))
    }
  }

  /// Multiplies both axes by a single factor read from `factorProvider` along `axis`.
  ///
  /// This is a convenience for uniform scaling based on one of the provider's axes.
  /// The axis-to-storage relationship is resolved using `mapping`.
  public func multiplyBoth(
    by factorProvider: Self,
    using axis: GeometryAxis,
    mapping: AxisMapping = .default
  ) -> Self {
    let factor = factorProvider.value(along: axis, mapping: mapping)
    return self.adjustBoth(mapping: mapping) { a, b in
      (a * factor, b * factor)
    }
  }

  /// Divides both axes by `divisor`, clamping the results at 0.
  ///
  /// Negative results are clamped to zero.
  /// If `divisor` is zero or non-finite, returns a value with both axes set to zero.
  public func divideBoth(by divisor: Component) -> Self {
    // Return zeros when divisor is zero or non-finite to guarantee a value.
    guard divisor.isFinite, divisor != 0 else {
      return self.adjustBoth { _ in 0 }
    }
    return self.adjustBoth { value in
      let divided = value / divisor
      return Swift.max(0, divided)
    }
  }

  /// Divides both axes by a single divisor read from `divisorProvider` along `axis`.
  ///
  /// The selected component (respecting `mapping`) is used as the divisor for both
  /// horizontal and vertical components; results are clamped to zero.
  /// If the selected divisor is zero or non-finite, returns a value with both axes set to zero.
  public func divideBoth(
    by divisorProvider: Self,
    using axis: GeometryAxis,
    mapping: AxisMapping = .default
  ) -> Self {
    let divisor = divisorProvider.value(along: axis, mapping: mapping)
    // Return zeros when divisor is zero or non-finite to guarantee a value.
    guard divisor.isFinite, divisor != 0 else {
      return self.adjustBoth(mapping: mapping) { _ in 0 }
    }
    return self.adjustBoth(mapping: mapping) { a, b in
      let aSafe = Swift.max(0, a / divisor)
      let bSafe = Swift.max(0, b / divisor)
      return (aSafe, bSafe)
    }
  }

  /// Failable variant: divides both axes by `divisor` and returns `nil` if `divisor` is zero or non-finite.
  ///
  /// On success, negative results are clamped to zero.
  public func dividingBothExactly(by divisor: Component) -> Self? {
    guard divisor.isFinite, divisor != 0 else { return nil }
    return self.adjustBoth { value in
      Swift.max(0, value / divisor)
    }
  }

  /// Failable variant: divides both axes by a single divisor read from `divisorProvider` along `axis`.
  ///
  /// Returns `nil` if the selected divisor is zero or non-finite. On success, results are clamped to zero.
  public func dividingBothExactly(
    by divisorProvider: Self,
    using axis: GeometryAxis,
    mapping: AxisMapping = .default
  ) -> Self? {
    let divisor = divisorProvider.value(along: axis, mapping: mapping)
    guard divisor.isFinite, divisor != 0 else { return nil }
    return self.adjustBoth(mapping: mapping) { a, b in
      (Swift.max(0, a / divisor), Swift.max(0, b / divisor))
    }
  }

  /// Applies a binary transform that can coordinate both axes together.
  ///
  /// The closure receives the current `(horizontal, vertical)` values and returns
  /// a new pair `(newHorizontal, newVertical)`. The read/write of components honors
  /// the provided `mapping`.
  ///
  /// Example (normalise to max):
  /// ```swift
  /// let size = CGSize(width: 2, height: 4)
  /// let normalised = size.adjustBoth { h, v in
  ///   let m = max(h, v)
  ///   return (h / m, v / m)
  /// }
  /// // => (0.5, 1.0)
  /// ```
  public func adjustBoth(
    mapping: AxisMapping = .default,
    _ transform: (Component, Component) -> (Component, Component)
  ) -> Self {
    let h = value(along: .horizontal, mapping: mapping)
    let v = value(along: .vertical, mapping: mapping)
    let (newH, newV) = transform(h, v)

    let result =
      self
      .setting(newH, along: .horizontal, mapping: mapping)
      .setting(newV, along: .vertical, mapping: mapping)
    return result
  }

}
