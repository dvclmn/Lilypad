//
//  TouchMapping.swift
//  Lilypad
//
//  Created by Dave Coleman on 4/4/2026.
//

import Foundation

/// How a source rectangle occupies a destination rectangle.
///
/// These policies resolve geometry only. They never clip, clamp or discard input.
/// Capture always delivers normalised touches, independently of this choice.
public enum TouchMapping: String, Equatable, Codable, Sendable, CaseIterable, Identifiable {
  /// Centre the whole source inside the destination, preserving its proportions.
  /// Some destination regions may be unreachable.
  case fit

  /// Centre and enlarge the source until it covers the destination, preserving
  /// its proportions. Some touches may land outside the destination.
  case fill

  /// Map every source corner to its destination corner. Unequal axis scales
  /// can distort the shape of physical finger movements.
  case stretch

  public var id: String { rawValue }
}

extension TouchMapping {
  public var displayName: String {
    rawValue.capitalized
  }
}
extension TouchMapping: CustomStringConvertible {
  public var description: String { displayName }
}
