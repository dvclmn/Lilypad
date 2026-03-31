//
//  CGPoint.swift
//  InteractionKit
//
//  Created by Dave Coleman on 30/3/2026.
//

import Foundation

extension CGSize {
  package var midpoint: CGPoint {
    return CGPoint(x: width / 2, y: height / 2)
  }
}
