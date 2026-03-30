//
//  ConversionSafetyCheck.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 27/2/2026.
//

import Foundation

private struct SafetyMessages {
  static let nonNegative = "Grid length must be non-negative"
  static let positiveFinite = "Unit length must be positive and finite"
}

// MARK: - Predicate (no side effects)

package func isSafeToConvert<Value: BinaryInteger>(
  _ value: Value,
  using unitLength: CGFloat
) -> Bool {
  value >= 0 && unitLength.isFiniteAndGreaterThanZero
}

package func isSafeToConvert<Value: BinaryFloatingPoint>(
  _ value: Value,
  using unitLength: CGFloat
) -> Bool {
  value >= 0 && unitLength.isFiniteAndGreaterThanZero
}

// MARK: - Debug assertions (no-op in Release)

@inline(__always)
package func assertSafeToConvert<Value: BinaryInteger>(
  _ value: Value,
  using unitLength: CGFloat,
  file: StaticString = #fileID,
  line: UInt = #line
) {
  assert(
    value >= 0,
    SafetyMessages.nonNegative,
    file: file,
    line: line
  )
  assert(
    unitLength.isFiniteAndGreaterThanZero,
    SafetyMessages.positiveFinite,
    file: file,
    line: line
  )
}

@inline(__always)
package func assertSafeToConvert<Value: BinaryFloatingPoint>(
  _ value: Value,
  using unitLength: CGFloat,
  file: StaticString = #fileID,
  line: UInt = #line
) {
  assert(
    value >= 0,
    SafetyMessages.nonNegative,
    file: file,
    line: line
  )
  assert(
    unitLength.isFiniteAndGreaterThanZero,
    SafetyMessages.positiveFinite,
    file: file,
    line: line
  )
}

// MARK: - Runtime enforcement (traps in Debug and Release)

@inline(__always)
package func preconditionSafeToConvert<Value: BinaryInteger>(
  _ value: Value,
  using unitLength: CGFloat,
  file: StaticString = #fileID,
  line: UInt = #line
) {
  precondition(
    value >= 0,
    SafetyMessages.nonNegative,
    file: file,
    line: line
  )
  precondition(
    unitLength.isFiniteAndGreaterThanZero,
    SafetyMessages.positiveFinite,
    file: file,
    line: line
  )
}

@inline(__always)
package func preconditionSafeToConvert<Value: BinaryFloatingPoint>(
  _ value: Value,
  using unitLength: CGFloat,
  file: StaticString = #fileID,
  line: UInt = #line
) {
  precondition(
    value >= 0,
    SafetyMessages.nonNegative,
    file: file,
    line: line
  )
  precondition(
    unitLength.isFiniteAndGreaterThanZero,
    SafetyMessages.positiveFinite,
    file: file,
    line: line
  )
}
