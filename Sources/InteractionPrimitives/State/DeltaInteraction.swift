//
//  DeltaInteraction.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 14/3/2026.
//

import Foundation
import GeometryPrimitives

extension ContinuousInteraction where Value == Size<ScreenSpace> {
  public mutating func updateDelta(
    _ screenDelta: CGSize,
    phase: InteractionPhase,
  ) {
    let delta = Value(fromCGSize: screenDelta)
    self.value += delta
    self.phase = phase
  }
}
