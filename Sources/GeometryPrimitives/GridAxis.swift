//
//  Model+GridDimension.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/7/2025.
//

import SwiftUI

/// Note: `GridAxis` is about how indices progress across the grid,
/// not about how the things themselves are shaped.
///
/// Even though a column is (in my brain) usually a 'vertical thing', in
/// terms of indices, it is horizontal.
///
/// ```
///    x →  0   1   2
///  y    ┌───┬───┬───┐
///  ↓    │   │   │   │   row 0
///       ├───┼───┼───┤
///       │   │   │   │   row 1
///       ├───┼───┼───┤
///       │   │   │   │   row 2
///
/// ```
//@CasePathable
public enum GridAxis: String, Sendable, Codable, Equatable, Hashable, CaseIterable, Identifiable {
  case horizontal  // Column
  case vertical  // Row

  public static var column: Self { .horizontal }
  public static var row: Self { .vertical }

}

extension GridAxis: CustomStringConvertible {
  public var description: String { name }
}
extension GridAxis {
  public struct Set: OptionSet, Sendable, Hashable {
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
    public let rawValue: Int

    public static let horizontal = Self(rawValue: 1 << 0)
    public static let vertical = Self(rawValue: 1 << 1)
    public static let all: Self = [.horizontal, .vertical]
  }
}

extension GridAxis.Set {
  public var name: String {
    let nameH = "Horizontal"
    let nameV = "Vertical"

    if self.isEmpty { return "None" }
    if self == .horizontal { return nameH }
    if self == .vertical { return nameV }
    if self == .all { return "\(nameH) & \(nameV)" }

    var parts: [String] = []
    if contains(.horizontal) { parts.append(nameH) }
    if contains(.vertical) { parts.append(nameV) }
    return parts.joined(separator: " & ")
  }
}

extension GridAxis {
  public var id: String { rawValue }

  public var toSet: GridAxis.Set {
    switch self {
      case .horizontal: [.horizontal]
      case .vertical: [.vertical]
    }
  }

  public var locationKeyPath: WritableKeyPath<CGPoint, CGFloat> {
    switch self {
      case .horizontal: \.x
      case .vertical: \.y
    }
  }

  public var sizeKeyPath: KeyPath<CGSize, CGFloat> {
    switch self {
      case .horizontal: \.width
      case .vertical: \.height
    }
  }

  public var isHorizontal: Bool { self == .horizontal }
  public var isVertical: Bool { self == .vertical }

  public var opposing: Self {
    switch self {
      case .horizontal: .vertical
      case .vertical: .horizontal
    }
  }


  //  public var numberingFrameSize: (CGFloat?, CGFloat?) {
  //    return switch self {
  //      case .horizontal: (nil, Self.fixedLength)
  //      case .vertical: (Self.fixedLength, nil)
  //    }
  //  }

  public var cellNumberTextAlignment: UnitPoint {
    switch self {
      case .horizontal: .center
      case .vertical: .trailing
    }
  }

  public var numberingShapeAlignment: Alignment {
    switch self {
      case .horizontal: .top
      case .vertical: .leading
    }
  }

  public func axisOffset(
    frameInViewport frame: CGRect
  ) -> CGSize {
    return switch self {
      case .horizontal:
        CGSize(
          width: frame.origin.x,
          height: 0,
        )
      case .vertical:
        CGSize(
          /// Width is zero as I don't want to decouple
          width: 0,
          height: frame.origin.y,
        )

    }
  }

  public func hasOverflow(
    artworkFrameInViewport: CGRect?,
    buffer: CGFloat,
  ) -> Bool {

    guard let artworkFrameInViewport else { return false }
    switch self {
      case .horizontal:
        let minX = artworkFrameInViewport.minX - buffer
        let hasOverflow: Bool = minX < 0
        return hasOverflow

      case .vertical:
        let minY = artworkFrameInViewport.minY - buffer
        let hasOverflow: Bool = minY < 0
        return hasOverflow
    }
  }

}

/// Metadata
extension GridAxis {

  public var name: String {
    switch self {
      case .horizontal: "Horizontal"
      case .vertical: "Vertical"
    }
  }

  public var altName02: String {
    switch self {
      case .horizontal: "Width"
      case .vertical: "Height"
    }
  }

  public var altName: String {
    switch self {
      case .horizontal: "Columns"
      case .vertical: "Rows"
    }
  }
  public var icon: String {
    switch self {
      case .horizontal: "arrow.left.and.right.text.vertical"
      case .vertical: "arrow.up.and.down.text.horizontal"
    }
  }

}

extension GridAxis {
  public var toSwiftUIAxis: Axis {
    switch self {
      case .horizontal: .horizontal
      case .vertical: .vertical
    }
  }
}

extension Axis {
  public var toGridAxis: GridAxis {
    switch self {
      case .horizontal: .horizontal
      case .vertical: .vertical
    }
  }
}
