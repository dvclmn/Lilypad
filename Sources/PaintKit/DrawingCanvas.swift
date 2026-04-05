//
//  DrawingCanvas.swift
//  LilyPadDemo
//

import InteractionKit
import SwiftUI

public struct DrawingCanvas: View {
  private let engine: StrokeEngine

  /// Controls speed-to-width mapping for all strokes.
//  private let brushStyle: BrushStyle

  /// Subdivisions per segment in the Catmull-Rom step. Higher = smoother
  /// curves but more points to process. 8 is a good default.
  private let catmullSteps: Int

  /// Colours assigned to fingers by their `touchOrder`.
//  private static let fingerColours: [Color] = [
//    .white, .blue, .green, .orange, .purple,
//    .red, .yellow, .cyan, .pink, .mint,
//  ]

  public init(
    engine: StrokeEngine,
//    brushStyle: BrushStyle = .init(),
    catmullSteps: Int = 8,
  ) {
    self.engine = engine
//    self.brushStyle = brushStyle
    self.catmullSteps = catmullSteps
  }

  public var body: some View {
    Canvas(
      opaque: true,
      rendersAsynchronously: true,
    ) { context, size in

      let bgRect = CGRect(origin: .zero, size: size)
      context.fill(Path(bgRect), with: .color(.black))

      for stroke in engine.filteredStrokes(using: .distance(minSeparation: 6)) {
        renderStroke(
          for: .completed,
//          for: .completed(stroke.style),
          points: stroke.points,
          touchOrder: stroke.touchOrder,
          in: &context,
        )
      }
      for (_, stroke) in engine.activeStrokes {
        renderStroke(
          for: .active,
          points: stroke.points,
          touchOrder: stroke.touchOrder,
          in: &context,
        )
      }
    }
  }
}

extension DrawingCanvas {

  private func renderStroke(
    for phase: StrokePhase,
    points: [StrokePoint],
    touchOrder: Int,

    in context: inout GraphicsContext,
  ) {
    guard points.count >= 2 else { return }

    let placeholderColour: Color = .gray
    let opacity = phase.isActive ? 0.6 : 1.0
//    let style = phase.style ?? engine.brushStyle

    let path = buildPath(from: points, style: style)
    context.fill(path, with: .color(placeholderColour.opacity(opacity)))
  }

  private func buildPath(
    from points: [StrokePoint],
    style: BrushStyle,
  ) -> Path {
    /// Extract parallel arrays for positions and speed values
    let positions = points.map(\.position)
    let speeds = points.map(\.speed)

    /// Densify using Catmull-Rom, interpolating both position and speed
    /// in lockstep so width tracks the actual curve geometry
    let sampled = CatmullRom.sample(
      positions: positions,
      values: speeds,
      steps: catmullSteps,
    )

    /// Feed into the variable-width builder
    var path = VariableWidthPath()
    for (position, speed) in sampled {
      path.addPoint(
        to: position,
        rawWidth: style.width(for: speed),
      )
    }

    /// Generate filled outline (smooth quad-curve edges)
    return path.generatePath(usesSmoothCurves: true)
  }
}

