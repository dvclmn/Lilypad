//
//  StrokeEngine.swift
//  LilypadDemo
//

import Lilypad
import SwiftUI

@Observable
public final class StrokeEngine {

  /// Strokes currently being drawn, keyed by touch ID.
  public private(set) var activeStrokes: [TouchID: ActiveStroke] = [:]

  /// Strokes that have been completed (finger lifted).
  //  public private(set) var completedStrokes: [Stroke] = []

  public private(set) var brushStyle: BrushStyle = .default

  public init() {}
}

extension StrokeEngine {

  public var pressure: CGFloat {
    guard let firstStroke = activeStrokes.values.first,
      let firstPoint = firstStroke.points.first
    else { return 0 }
    return firstPoint.pressure
  }

  /// Process a frame of touch input.
  ///
  /// Call this from the `.trackpadTouches()` callback every time touches
  /// update. The engine handles the full lifecycle: creating strokes on
  /// `began`, appending points on `changed`, and finalising on `ended`.
  public func processTouches(_ touches: [TouchPoint]) -> [Stroke] {

    var completed: [Stroke] = []
    for touch in touches where !touch.isResting {
      switch touch.phase {
        case .began:
          beginStroke(for: touch)

        case .changed:
          continueStroke(for: touch)

        case .ended, .cancelled:
          completed = finishStroke(for: touch)

        default: break
      }
    }
    return completed
  }

  //  public func setCompleted(_ strokes: [Stroke]) {
  //    self.completedStrokes = strokes
  //  }

  /// Remove all completed strokes.
  //  public func clear() {
  //    completedStrokes.removeAll()
  //  }

  /// Undo the most recent completed stroke. Returns `true` if there was
  /// something to undo.
  //  @discardableResult
  //  public func undo() -> Bool {
  //    completedStrokes.popLast() != nil
  //  }

  /// Total points across all completed strokes.
  //  public var totalPointCount: Int {
  //    completedStrokes.reduce(0) { $0 + $1.points.count }
  //  }

  /// Whether any finger is currently drawing.
  public var isDrawing: Bool { !activeStrokes.isEmpty }

}

// MARK: - Stroke helpers

extension StrokeEngine {

  private func beginStroke(
    for touch: TouchPoint
  ) {
    let point = StrokePoint(
      position: touch.position,
      speed: touch.magnitude,
      touchOrder: touch.touchOrder,
      pressure: touch.pressure,
    )
    activeStrokes[touch.id] = ActiveStroke(
      id: touch.id,
      touchOrder: touch.touchOrder,
      points: [point],
    )
  }

  private func continueStroke(for touch: TouchPoint) {
    guard var stroke = activeStrokes[touch.id] else { return }

    stroke.points.append(
      StrokePoint(
        position: touch.position,
        speed: touch.magnitude,
        touchOrder: touch.touchOrder,
        pressure: touch.pressure,
      ))
    activeStrokes[touch.id] = stroke
  }

  private func finishStroke(for touch: TouchPoint) -> [Stroke] {
    guard let stroke = activeStrokes.removeValue(forKey: touch.id)
    else { return [] }
    guard stroke.points.count >= 2 else { return [] }

    let new = Stroke(
      touchOrder: stroke.touchOrder,
      points: stroke.points,
      style: brushStyle,
    )

    return [new]
  }
}

// MARK: - Rendering helpers

//extension StrokeEngine {
//  /// Returns copies of completed strokes with their points filtered.
//  /// The engine's stored data stays untouched (raw, full-fidelity capture).
//  public func filteredStrokes(
//    using filter: StrokeFilterType
//  ) -> [Stroke] {
//    switch filter {
//      case .none:
//        return completedStrokes
//      default:
//        return completedStrokes.map { stroke in
//          Stroke(
//            touchOrder: stroke.touchOrder,
//            points: filter.applied(to: stroke.points),
//            style: stroke.style,
//          )
//        }
//    }
//  }
//}
