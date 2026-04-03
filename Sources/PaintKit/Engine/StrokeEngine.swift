//
//  StrokeEngine.swift
//  LilyPadDemo
//

import SwiftUI
import LilyPad

@Observable
public final class StrokeEngine {

  /// Strokes currently being drawn, keyed by touch ID.
  public private(set) var activeStrokes: [TouchID: ActiveStroke] = [:]

  /// Strokes that have been completed (finger lifted).
  public private(set) var completedStrokes: [CompletedStroke] = []

  // MARK: - Configuration

  /// Minimum distance (in points) between consecutive stroke points.
  /// Higher values reduce point density and improve performance at the cost of resolution.
  public var minimumPointDistance: CGFloat = 2.0

  public init() {}
}

extension StrokeEngine {

  /// Process a frame of touch input.
  ///
  /// Call this from the `.trackpadTouches()` callback every time touches
  /// update. The engine handles the full lifecycle: creating strokes on
  /// `began`, appending points on `changed`, and finalising on `ended`.
  public func processTouches(_ touches: [TouchPoint]) {
    for touch in touches where !touch.isResting {
      switch touch.phase {
        case .began: beginStroke(for: touch)
        case .changed: continueStroke(for: touch)
        case .ended, .cancelled: finishStroke(for: touch)
        default: break
      }
    }
  }

  /// Remove all completed strokes.
  public func clear() {
    completedStrokes.removeAll()
  }

  /// Undo the most recent completed stroke. Returns `true` if there was
  /// something to undo.
  @discardableResult
  public func undo() -> Bool {
    completedStrokes.popLast() != nil
  }

  /// Total points across all completed strokes.
  public var totalPointCount: Int {
    completedStrokes.reduce(0) { $0 + $1.points.count }
  }

  /// Whether any finger is currently drawing.
  public var isDrawing: Bool { !activeStrokes.isEmpty }

}

// MARK: - Stroke helpers

extension StrokeEngine {

  private func beginStroke(for touch: TouchPoint) {
    let point = StrokePoint(
      position: touch.position,
      speed: touch.magnitude,
      touchOrder: touch.touchOrder,
    )
    activeStrokes[touch.id] = ActiveStroke(
      id: touch.id,
      touchOrder: touch.touchOrder,
      points: [point],
    )
  }

  private func continueStroke(for touch: TouchPoint) {
    guard var stroke = activeStrokes[touch.id] else { return }

    if let last = stroke.points.last {
      let dx = touch.position.x - last.position.x
      let dy = touch.position.y - last.position.y
      if sqrt(dx * dx + dy * dy) < minimumPointDistance { return }
    }

    stroke.points.append(
      StrokePoint(
        position: touch.position,
        speed: touch.magnitude,
        touchOrder: touch.touchOrder,
      ))
    activeStrokes[touch.id] = stroke
  }

  private func finishStroke(for touch: TouchPoint) {
    guard let stroke = activeStrokes.removeValue(forKey: touch.id) else { return }
    guard stroke.points.count >= 2 else { return }

    completedStrokes.append(
      CompletedStroke(
        points: stroke.points,
        touchOrder: stroke.touchOrder,
      ))
  }
}
