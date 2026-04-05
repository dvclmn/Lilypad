//
//  StrokePhase.swift
//  InteractionKit
//
//  Created by Dave Coleman on 5/4/2026.
//

/// Need to figure out how to allow a Completed stroke to carry it's brush style
enum StrokePhase {
  case active
  case completed
//  case completed(BrushStyle)
  
  var isActive: Bool {
    if case .active = self {
      return true
    }
    return false
  }
  
//  var style: BrushStyle? {
//    switch self {
//      case .active: nil
//      case .completed(let brushStyle): brushStyle
//    }
//  }
}
