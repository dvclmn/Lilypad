//
//  IndicatorsView.swift
//  Lilypad
//
//  Created by Dave Coleman on 7/5/2025.
//

import SwiftUI

/// Debug overlay that renders numbered circles at each active touch position.
///
/// Finger numbers are stable — they reflect ``TouchPoint/touchOrder``,
/// so the first finger placed stays "1" even as other fingers come and go.
public struct TouchIndicatorsView: View {
  @Environment(\.showsTrackpadTouchIndicators) private var isVisible

  public let touches: [MappedTouchPoint]

  public init(touches: [MappedTouchPoint]) { self.touches = touches }

  private let indicatorDiameter: CGFloat = 40

  public var body: some View {
    if isVisible {
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
    }
  }

  private func positionLabel(_ point: CGPoint) -> String {
    "\(Double(point.x).formatted(.number.precision(.fractionLength(0)))), \(Double(point.y).formatted(.number.precision(.fractionLength(0))))"
  }
}
