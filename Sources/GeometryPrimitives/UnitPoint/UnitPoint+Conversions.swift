//
//  UnitPoint+Conversions.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 15/3/2026.
//

import SwiftUI

extension UnitPoint {

  public var opposing: UnitPoint {
    switch self {
      case .top: return .bottom
      case .bottom: return .top
      case .leading: return .trailing
      case .trailing: return .leading
      case .topLeading: return .bottomTrailing
      case .topTrailing: return .bottomLeading
      case .bottomLeading: return .topTrailing
      case .bottomTrailing: return .topLeading
      default: return .center
    }
  }

  public var toAlignment: Alignment {
    switch self {
      case .top: return .top
      case .bottom: return .bottom
      case .leading: return .leading
      case .trailing: return .trailing
      case .topLeading: return .topLeading
      case .topTrailing: return .topTrailing
      case .bottomLeading: return .bottomLeading
      case .bottomTrailing: return .bottomTrailing
      default: return .center
    }
  }

}
