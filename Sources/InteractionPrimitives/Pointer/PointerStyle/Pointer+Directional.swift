//
//  Pointer+Directional.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/2/2026.
//

import SwiftUI

// MARK: - Enums
public enum HorizontalDirectionCompatible {
  case leading
  case trailing
}
public enum VerticalDirectionCompatible {
  case up
  case down
}

// MARK: - Option Sets
extension HorizontalDirectionCompatible {
  public struct Set: OptionSet, Sendable {
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
    public let rawValue: Int

    public static let leading = Self(rawValue: 1 << 0)
    public static let trailing = Self(rawValue: 1 << 1)
    public static let all: Self = [.leading, .trailing]
  }
}

extension VerticalDirectionCompatible {
  public struct Set: OptionSet, Sendable {
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
    public let rawValue: Int

    public static let up = Self(rawValue: 1 << 0)
    public static let down = Self(rawValue: 1 << 1)
    public static let all: Self = [.up, .down]
  }
}

// MARK: - Conversions
extension VerticalDirectionCompatible.Set {
  @available(macOS 15, *)
  var verticalDirection: VerticalDirection.Set {
    var result: VerticalDirection.Set = []
    if self.contains(.up) { result.insert(.up) }
    if self.contains(.down) { result.insert(.down) }
    return result
  }
}

extension HorizontalDirectionCompatible.Set {
  @available(macOS 15, *)
  var horizontalDirection: HorizontalDirection.Set {
    var result: HorizontalDirection.Set = []
    if self.contains(.leading) { result.insert(.leading) }
    if self.contains(.trailing) { result.insert(.trailing) }
    return result
  }
}
