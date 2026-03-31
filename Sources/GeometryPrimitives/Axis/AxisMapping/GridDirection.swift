//
//  GridDirection.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/2/2026.
//

import SwiftUI

public enum GridDirection {
  case start
  case center
  case end
}

extension AxisMapping {
  /// Maps a logical direction (Start/Center/End) to a physical SwiftUI Alignment component.
  public func alignmentComponent(for axis: GeometryAxis, direction: GridDirection) -> Any {
    let physicalAxis = self.map(axis)
    switch (physicalAxis, direction) {
      case (.horizontal, .start): return HorizontalAlignment.leading
      case (.horizontal, .center): return HorizontalAlignment.center
      case (.horizontal, .end): return HorizontalAlignment.trailing
      case (.vertical, .start): return VerticalAlignment.top
      case (.vertical, .center): return VerticalAlignment.center
      case (.vertical, .end): return VerticalAlignment.bottom
    }
  }
}
