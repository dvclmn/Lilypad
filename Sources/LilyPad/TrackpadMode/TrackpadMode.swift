//
//  TrackpadMode.swift
//  InteractionKit
//
//  Created by Dave Coleman on 4/4/2026.
//

public enum TrackpadMode {

  /// Trackpad touches enabled, standard pointer behaviour
  case active

  /// Trackpad touches enabled, pointer is disabled to
  /// prevent accidental clicking / loss of window focus
  case activePointerHidden

  /// Touches disabled, nothing captured
  case inactive
}

extension TrackpadMode {
  public var shouldHidePointer: Bool { self == .activePointerHidden }
  public var isEnabled: Bool { self == .activePointerHidden || self == .active }
}

extension TrackpadMode: CustomStringConvertible {
  public var description: String {
    switch self {
      case .active: "Active"
      case .activePointerHidden: "Active (Pointer Hidden)"
      case .inactive: "Disabled"
    }
  }
}
