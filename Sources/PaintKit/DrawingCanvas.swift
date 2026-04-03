//
//  DrawingCanvas.swift
//  LilyPadDemo
//

import InteractionKit
import SwiftUI

public struct DrawingCanvas: View {
  private let engine: StrokeEngine

  /// Controls speed-to-width mapping for all strokes.
  private let brushStyle: BrushStyle

  /// Subdivisions per segment in the Catmull-Rom step. Higher = smoother
  /// curves but more points to process. 8 is a good default.
  private let catmullSteps: Int

  /// Colours assigned to fingers by their `touchOrder`.
  private static let fingerColours: [Color] = [
    .white, .blue, .green, .orange, .purple,
    .red, .yellow, .cyan, .pink, .mint,
  ]

  public init(
    engine: StrokeEngine,
    brushStyle: BrushStyle = .init(),
    catmullSteps: Int = 8,
  ) {
    self.engine = engine
    self.brushStyle = brushStyle
    self.catmullSteps = catmullSteps
  }

  public var body: some View {
    Canvas(
      opaque: true,
      rendersAsynchronously: true,
    ) { context, size in

      let bgRect = CGRect(origin: .zero, size: size)
      context.fill(Path(bgRect), with: .color(.black))

      for stroke in engine.completedStrokes {
        renderStroke(
          stroke.points,
          touchOrder: stroke.touchOrder,
          opacity: 1,
          in: &context,
        )
      }
      for (_, stroke) in engine.activeStrokes {
        renderStroke(
          stroke.points,
          touchOrder: stroke.touchOrder,
          opacity: 0.6,
          in: &context,
        )
      }
    }
  }
}

extension DrawingCanvas {

  private func renderStroke(
    _ points: [StrokePoint],
    touchOrder: Int,
    opacity: Double,
    in context: inout GraphicsContext,
  ) {
    guard points.count >= 2 else { return }

    let colour = Self.fingerColours[touchOrder % Self.fingerColours.count]
    let path = buildPath(from: points)
    context.fill(path, with: .color(colour.opacity(opacity)))
  }

  private func buildPath(from points: [StrokePoint]) -> Path {
    /// 1. Extract parallel arrays for positions and speed values
    let positions = points.map(\.position)
    let speeds = points.map(\.speed)

    /// 2. Densify using Catmull-Rom, interpolating both position and speed
    /// in lockstep so width tracks the actual curve geometry
    let sampled = CatmullRom.sample(
      positions: positions,
      values: speeds,
      steps: catmullSteps,
    )

    /// 3. Feed into the variable-width builder
    var vwp = VariableWidthPath()
    for (position, speed) in sampled {
      vwp.addPoint(to: position, rawWidth: brushStyle.width(for: speed))
    }

    /// 4. Generate filled outline (smooth quad-curve edges)
    return vwp.generatePath(usesSmoothCurves: true)
  }
}
