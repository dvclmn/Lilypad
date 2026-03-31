//
//  ClosedRange.swift
//  InteractionKit
//
//  Created by Dave Coleman on 30/3/2026.
//

import Foundation

extension ClosedRange {
  public var isGreaterThanZero: Bool { lowerBound < upperBound }
}
