//
//  TrackpadGuideVisibility.swift
//  InteractionKit
//
//  Created by Dave Coleman on 6/4/2026.
//

public enum TrackpadGuideVisibility: String, Codable, Equatable, Sendable, Hashable, CaseIterable, Identifiable {
  case always
  case drawingMode
  case never
}

extension TrackpadGuideVisibility {
  public var id: String { rawValue }
  public func displayName(modeLabel: String? = nil) -> String {
    switch self {
      case .always: return "Always"
      case .drawingMode:
        let label = modeLabel ?? "Trackpad"
        return "\(label) Mode"
      case .never: return "Never"
    }
  }
  
  public var icon: String {
    switch self {
      case .always: "rectangle"
      case .drawingMode: "rectangle.dashed"
      case .never: "rectangle.slash"
    }
  }
}
