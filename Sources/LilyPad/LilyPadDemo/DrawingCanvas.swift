//
//  DrawingCanvas.swift
//  LilyPadDemo
//

import SwiftUI
import GeometryPrimitives

/// Renders strokes from a ``StrokeEngine`` using SwiftUI Canvas.
///
/// ## Rendering pipeline
///
/// For each stroke (active or completed):
///
/// 1. **Catmull-Rom sampling** — the raw captured points are densified using
///    Catmull-Rom interpolation. Positions *and* speed values are interpolated
///    together, so the width follows the actual curve, not just the control points.
///
/// 2. **Width mapping** — each sampled point's speed is passed through
///    ``BrushStyle/width(for:)`` to get a line width. Slower = wider.
///
/// 3. **Variable-width fill** — a ``VariableWidthPath`` accumulates left/right
///    edge offsets and generates a filled outline path.
///
/// 4. **Canvas fill** — the filled path is drawn with `context.fill()`.
///
/// ## Customising
///
/// - Swap in a different ``BrushStyle`` to change the speed-to-width mapping.
/// - Adjust ``catmullSteps`` to trade smoothness for performance.
/// - Replace the fill call with a texture stamp or blend mode for richer effects.
///
public struct DrawingCanvas: View {
  let engine: StrokeEngine

  /// Controls speed-to-width mapping for all strokes.
  public var brushStyle: BrushStyle = .init()

  /// Subdivisions per segment in the Catmull-Rom step. Higher = smoother
  /// curves but more points to process. 8 is a good default.
  public var catmullSteps: Int = 8

  /// Colours assigned to fingers by their `touchOrder`.
  private static let fingerColours: [Color] = [
    .white, .blue, .green, .orange, .purple,
    .red, .yellow, .cyan, .pink, .mint,
  ]

  public var body: some View {
    Canvas { context, _ in
      for stroke in engine.completedStrokes {
        renderStroke(stroke.points, touchOrder: stroke.touchOrder, opacity: 1, in: &context)
      }
      for (_, stroke) in engine.activeStrokes {
        renderStroke(stroke.points, touchOrder: stroke.touchOrder, opacity: 0.6, in: &context)
      }
    }
    .background(.black)
  }

  // MARK: - Private

  private func renderStroke(
    _ points: [StrokePoint],
    touchOrder: Int,
    opacity: Double,
    in context: inout GraphicsContext
  ) {
    guard points.count >= 2 else { return }

    let colour = Self.fingerColours[touchOrder % Self.fingerColours.count]
    let path = buildPath(from: points)
    context.fill(path, with: .color(colour.opacity(opacity)))
  }

  private func buildPath(from points: [StrokePoint]) -> Path {
    // 1. Extract parallel arrays for positions and speed values
    let positions = points.map(\.position)
    let speeds = points.map(\.speed)

    // 2. Densify using Catmull-Rom, interpolating both position and speed
    //    in lockstep so width tracks the actual curve geometry
    let sampled = CatmullRom.sample(
      positions: positions,
      values: speeds,
      steps: catmullSteps
    )

    // 3. Feed into the variable-width builder
    var vwp = VariableWidthPath()
    for (position, speed) in sampled {
      vwp.addPoint(to: position, rawWidth: brushStyle.width(for: speed))
    }

    // 4. Generate filled outline (smooth quad-curve edges)
    return vwp.generatePath(usesSmoothCurves: true)
  }
}
