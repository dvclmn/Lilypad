//
//  AdjustOperator.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 20/1/2026.
//

//prefix operator +
prefix operator *

/// ```
/// point.adjust(.horizontal, using: +20)
/// point.adjust(.vertical, using: *0.5)
///
/// ```
public struct Operation<T> {
  let apply: (T) -> T
}

public prefix func + <T: BinaryFloatingPoint>(rhs: T) -> Operation<T> {
  Operation { $0 + rhs }
}

public prefix func + <T: AdditiveArithmetic>(rhs: T) -> Operation<T> {
  Operation { $0 + rhs }
}

public prefix func * <T: Numeric>(rhs: T) -> Operation<T> {
  Operation { $0 * rhs }
}
