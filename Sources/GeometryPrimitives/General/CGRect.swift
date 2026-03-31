//
//  CGRect.swift
//  InteractionKit
//
//  Created by Dave Coleman on 29/3/2026.
//

import Foundation

extension CGRect {
  public static func boundingRect(
    from start: CGPoint, to end: CGPoint,
  ) -> CGRect {
    let size = CGSize(
      width: end.x - start.x,
      height: end.y - start.y,
    )
    return CGRect(origin: start, size: size).standardized
  }
}
