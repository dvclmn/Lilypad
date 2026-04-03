//
//  Compat+FrameResize.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/2/2026.
//

import SwiftUI

public enum FrameResizePositionCompatible: Int8, CaseIterable, Sendable {
  case top
  case leading
  case bottom
  case trailing
  case topLeading
  case topTrailing
  case bottomLeading
  case bottomTrailing
}

public enum FrameResizeDirectionCompatible: Int8, CaseIterable, Sendable {
  
  /// Indicates that the frame can be resized inwards to be smaller.
  case inward
  
  /// Indicates that the frame can be resized outwards to be larger.
  case outward
  
  case all
}

#if canImport(AppKit)
extension FrameResizePositionCompatible {
  @available(macOS 15, *)
  var resizePosition: FrameResizePosition {
    switch self {
      case .top: .top
      case .leading: .leading
      case .bottom: .bottom
      case .trailing: .trailing
      case .topLeading: .topLeading
      case .topTrailing: .topTrailing
      case .bottomLeading: .bottomLeading
      case .bottomTrailing: .bottomTrailing
    }
  }
}
extension FrameResizeDirectionCompatible {
  @available(macOS 15, *)
  var resizeDirection: FrameResizeDirection.Set {
    switch self {
      case .inward: .inward
      case .outward: .outward
      case .all: .all
    }
  }
}
#endif
