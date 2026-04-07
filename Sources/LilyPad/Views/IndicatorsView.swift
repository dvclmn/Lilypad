//
//  IndicatorsView.swift
//  LilyPad
//
//  Created by Dave Coleman on 7/5/2025.
//

import SwiftUI

/// Debug overlay that renders numbered circles at each active touch position.
///
/// Finger numbers are stable — they reflect ``TouchPoint/touchOrder``,
/// so the first finger placed stays "1" even as other fingers come and go.
struct TouchIndicatorsView: View {

  let touches: [TouchPoint]
//  let containerSize: CGSize

  private let indicatorDiameter: CGFloat = 40

  var body: some View {
    ForEach(touches) { touch in
      Circle()
        .fill(Color.blue.opacity(0.7))
        .frame(width: indicatorDiameter)
        .overlay {
          Text("\(touch.touchOrder + 1)")
            .font(.title2)
            .monospacedDigit()
        }
        .overlay(alignment: .bottom) {
          Text(positionLabel(touch.position))
            .monospaced()
            .font(.caption2)
            .fixedSize()
            .offset(y: -indicatorDiameter * 1.15)
        }
        .position(touch.position)
    }
    .allowsHitTesting(false)
//    .frame(width: containerSize.width, height: containerSize.height)
  }

  private func positionLabel(_ point: CGPoint) -> String {
    "\(Int(point.x)), \(Int(point.y))"
  }
}
