//
//  LayerMetadata.swift
//  Paperbark
//
//  Created by Dave Coleman on 20/4/2026.
//

import Foundation

public struct LayerMetadata: Codable, Equatable, Hashable, Sendable {
  public var name: String
  public var opacity: Double
  public var isVisible: Bool
  public var isLocked: Bool

  public init(
    name: String,
    opacity: Double = 1.0,
    isVisible: Bool = true,
    isLocked: Bool = false,
  ) {
    self.name = name
    self.opacity = opacity
    self.isVisible = isVisible
    self.isLocked = isLocked
  }
}
