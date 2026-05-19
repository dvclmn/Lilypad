//
//  CGSize+Trackpad.swift
//  Lilypad
//
//  Created by Dave Coleman on 24/6/2025.
//

import CoreGraphics

extension CGSize {
  /// Approximate aspect ratio of a MacBook trackpad (height / width).
  public static let trackpadAspectRatio: CGFloat = 10.0 / 16.0

  /// A reference trackpad size for layout calculations (700 x 437.5 pt).
  public static var trackpadSize: CGSize {
    let width: CGFloat = 700
    return CGSize(width: width, height: width * trackpadAspectRatio)
  }

  /// Returns true if both width and height are greater than zero
  public var isGreaterThanZero: Bool { width > 0 && height > 0 }
}
