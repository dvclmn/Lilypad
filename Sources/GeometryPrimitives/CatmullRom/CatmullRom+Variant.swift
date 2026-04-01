//
//  CatmullRom+Variant.swift
//  InteractionKit
//
//  Created by Dave Coleman on 1/4/2026.
//

import Foundation

extension CatmullRom {

  /// Parameterisation style controlling how the knot vector is computed.
  public enum Variant: String, Codable, Sendable {
    case uniform
    case centripetal
    case chordal

    var alpha: CGFloat {
      switch self {
        case .uniform: 0
        case .centripetal: 0.5
        case .chordal: 1
      }
    }

    public var name: String { self.rawValue.capitalized }

    public var icon: String {
      switch self {
        case .uniform: "eye"
        case .chordal: "eye"
        case .centripetal: "eye"
      //      case .none: "eye"
      }
    }

  }
}
