//
//  CGSize+Operators.swift
//  InteractionKit
//
//  Created by Dave Coleman on 31/3/2026.
//

import Foundation

// MARK: - Subtraction

public func - (lhs: CGSize, rhs: CGSize) -> CGSize {
  return CGSize(
    width: lhs.width - rhs.width,
    height: lhs.height - rhs.height
  )
}
public func - (lhs: CGSize, rhs: CGFloat) -> CGSize {
  return CGSize(
    width: lhs.width - rhs,
    height: lhs.height - rhs
  )
}
public func - (lhs: CGSize, rhs: CGPoint) -> CGSize {
  return CGSize(
    width: lhs.width - rhs.x,
    height: lhs.height - rhs.y
  )
}

// MARK: - Addition
public func + (lhs: CGSize, rhs: CGSize) -> CGSize {
  return CGSize(
    width: lhs.width + rhs.width,
    height: lhs.height + rhs.height
  )
}
public func + (lhs: CGSize, rhs: CGFloat) -> CGSize {
  return CGSize(
    width: lhs.width + rhs,
    height: lhs.height + rhs
  )
}

public func + (lhs: CGFloat, rhs: CGSize) -> CGSize {
  return CGSize(
    width: lhs + rhs.width,
    height: lhs + rhs.height
  )
}

public func += (lhs: inout CGSize, rhs: CGFloat) {
  lhs = lhs + rhs
}
public func += (lhs: inout CGSize, rhs: CGSize) {
  lhs.width += rhs.width
  lhs.height += rhs.height
}

// MARK: - Multiplication
public func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
  return CGSize(
    width: lhs.width * rhs,
    height: lhs.height * rhs
  )
}
public func * (lhs: CGSize, rhs: CGSize) -> CGSize {
  return CGSize(
    width: lhs.width * rhs.width,
    height: lhs.height * rhs.height
  )
}

// MARK: - Division
public func / (lhs: CGSize, rhs: CGSize) -> CGSize {
  precondition(rhs.width != 0 && rhs.height != 0, "Cannot divide by zero size")
  return CGSize(
    width: lhs.width / rhs.width,
    height: lhs.height / rhs.height
  )
}

public func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
  precondition(rhs != 0 && rhs != 0, "Cannot divide by zero size")
  return CGSize(
    width: lhs.width / rhs,
    height: lhs.height / rhs
  )
}

// MARK: - Unary

extension CGSize {
  public static prefix func - (size: CGSize) -> CGSize {
    CGSize(width: -size.width, height: -size.height)
  }
}
