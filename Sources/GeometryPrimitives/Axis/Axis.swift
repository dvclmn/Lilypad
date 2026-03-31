//
//  Axis.swift
//  Collection
//
//  Created by Dave Coleman on 30/10/2024.
//

import SwiftUI

extension Axis {
  public var toAxisSet: Axis.Set {
    switch self {
      case .horizontal: [.horizontal]
      case .vertical: [.vertical]
    }
  }
  public var toEdgeSet: Edge.Set {
    switch self {
      case .horizontal: .horizontal
      case .vertical: .vertical
    }
  }

  public var isHorizontal: Bool {
    self == .horizontal
  }

  public var isVertical: Bool {
    self == .vertical
  }

  public func getMinMax(
    _ axis: Axis.MinMax,
    mapping: AxisMapping = .default,
  ) -> Axis {
    switch mapping {
      case .identity:
        switch axis {
          case .minWidth, .maxWidth: .horizontal
          case .minHeight, .maxHeight: .vertical
        }
      case .transposed:
        switch axis {
          case .minWidth, .maxWidth: .vertical
          case .minHeight, .maxHeight: .horizontal
        }
    }

  }
}

extension Axis {
  public enum MinMax {
    case minWidth
    case maxWidth
    case minHeight
    case maxHeight
  }
}
