//
//  Interaction+Env.swift
//  InteractionKit
//
//  Created by Dave Coleman on 28/3/2026.
//

import SwiftUI

extension EnvironmentValues {

  @Entry public var panOffset: CGSize = .zero
  @Entry public var rotation: Angle = .zero

  // MARK: - Zoom
  @Entry public var zoomLevel: Double = 1.0
  @Entry public var zoomRange: ClosedRange<Double>?

  /// Will return unclamped if no zoom range found in the Environment
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndGreaterThanZero else { return 1.0 }
    return zoomLevel.clampedIfNeeded(to: zoomRange)
  }

  @Entry public var pointerStyle: PointerStyleCompatible?
}

