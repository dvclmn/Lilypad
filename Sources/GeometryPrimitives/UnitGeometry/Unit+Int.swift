//
//  Unit+Extensions.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 27/2/2026.
//

import Foundation

// MARK: - Unit Length variants

extension Int {

  public func toScreenLength(
    using unitLength: CGFloat,
    policy: ConversionSafetyPolicy = .assertDebug
  ) -> CGFloat {
    switch policy {
      case .checkOnly, .assertDebug:
        assertSafeToConvert(self, using: unitLength)

      case .enforceRuntime:
        preconditionSafeToConvert(self, using: unitLength)

    }
    return CGFloat(self) * unitLength
  }

  public func toScreenLengthIfPossible(
    using unitLength: CGFloat?,
    policy: ConversionSafetyPolicy = .checkOnly
  ) -> CGFloat? {
    guard let unitLength else { return nil }
    switch policy {
      case .checkOnly:
        guard isSafeToConvert(self, using: unitLength) else { return nil }

      case .assertDebug:
        assertSafeToConvert(self, using: unitLength)
        guard isSafeToConvert(self, using: unitLength) else { return nil }

      case .enforceRuntime:
        preconditionSafeToConvert(self, using: unitLength)
        guard isSafeToConvert(self, using: unitLength) else { return nil }

    }
    return CGFloat(self) * unitLength
  }
}

// MARK: - Unit Size variants

extension Int {
  public func toScreenLength(
    along axis: GeometryAxis,
    mapping: AxisMapping = .default,
    using unitSize: CGSize,
    policy: ConversionSafetyPolicy = .assertDebug
  ) -> CGFloat {
    let length = unitSize.value(along: axis, mapping: mapping)
    return toScreenLength(using: length, policy: policy)
  }

  public func toScreenLengthIfPossible(
    along axis: GeometryAxis,
    mapping: AxisMapping = .default,
    using unitSize: CGSize?,
    policy: ConversionSafetyPolicy = .checkOnly
  ) -> CGFloat? {
    guard let unitSize else { return nil }
    let length = unitSize.value(along: axis, mapping: mapping)
    return toScreenLengthIfPossible(using: length, policy: policy)
  }

}
