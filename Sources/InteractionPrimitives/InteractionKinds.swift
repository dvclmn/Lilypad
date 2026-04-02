//
//  InputKinds.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/3/2026.
//

import Foundation

public struct InteractionKinds: OptionSet, Sendable {
  
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static let swipe = Self(rawValue: 1 << 0)
  public static let pinch = Self(rawValue: 1 << 1)
  public static let pointerHover = Self(rawValue: 1 << 2)
  public static let pointerTap = Self(rawValue: 1 << 3)
  public static let pointerDrag = Self(rawValue: 1 << 4)
  
  
  /// Default for most tools.
  public static let pointerOnly: Self = [.pointerTap, .pointerDrag]
  
  /// Convenience for tools that want hover as well as pointer events.
  public static let pointerAndHover: Self = [.pointerTap, .pointerDrag, .pointerHover]
  
  public static let all: Self = [
    .swipe,
    .pinch,
    .pointerHover,
    .pointerTap,
    .pointerDrag
  ]
}
