//
//  StrokePhase.swift
//  InteractionKit
//
//  Created by Dave Coleman on 5/4/2026.
//

import Foundation

/// Need to figure out how to allow a Completed stroke to carry it's brush style
enum StrokePhase: Hashable {
  case active
  case completed(BrushStyle)

  enum Meta: String, CaseIterable, Identifiable, Hashable {
    case active
    case completed
  }
}

extension StrokePhase {

  var isActive: Bool {
    if case .active = self {
      return true
    }
    return false
  }
  var style: BrushStyle? {
    switch self {
      case .active: nil
      case .completed(let brushStyle): brushStyle
    }
  }

  init?(fromMeta meta: Self.Meta) {
    switch meta {
      case .active: self = .active
      case .completed: return nil
    }
  }

  var meta: Self.Meta { .init(fromParent: self) }

}

extension StrokePhase.Meta {
  init(fromParent parent: StrokePhase) {
    self =
      switch parent {
        case .active: .active
        case .completed: .completed
      }
  }
  var id: String { rawValue }
  var parent: StrokePhase? { .init(fromMeta: self) }
}
