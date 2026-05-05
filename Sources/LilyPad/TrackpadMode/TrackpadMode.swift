//
//  TrackpadMode.swift
//  InteractionKit
//
//  Created by Dave Coleman on 4/4/2026.
//

/// Consider expanding to support `TrackpadMode.Behaviours`
/// supplied as assoc. value etc
public enum TrackpadMode: Equatable {

  /// Trackpad touches enabled, standard pointer behaviour
  case active(hidesPointer: Bool)

  /// Trackpad touches enabled, pointer is disabled to
  /// prevent accidental clicking / loss of window focus
  //  case activePointerHidden

  /// Touches disabled, nothing captured
  case inactive
}

extension TrackpadMode {
  public var shouldHidePointer: Bool {
    if case .active(hidesPointer: true) = self {
      return true
    }
    return false
  }

  public var isEnabled: Bool {
    if case .active(_) = self {
      return true
    }
    return false
  }
}

extension TrackpadMode: CustomStringConvertible {
  public var description: String {
    switch self {
      case .active(let hidesPointer): "Active" + (hidesPointer ? " (Pointer Hidden)" : "")
      case .inactive: "Disabled"
    }
  }
}
