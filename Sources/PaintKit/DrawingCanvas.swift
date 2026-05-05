//
//  DrawingCanvas.swift
//  LilypadDemo
//

import BasePrimitives
import SwiftUI

public struct DrawingCanvas: View {
  private let engine: StrokeEngine

  let layers: [any DrawingLayer]
  /// Controls speed-to-width mapping for all strokes.
  //  private let brushStyle: BrushStyle

  /// Subdivisions per segment in the Catmull-Rom step. Higher = smoother
  /// curves but more points to process. 8 is a good default.
  private let catmullSteps: Int

  public init(
    engine: StrokeEngine,
    layers: [any DrawingLayer],
    //    brushStyle: BrushStyle = .init(),
    catmullSteps: Int = 8,
  ) {
    self.engine = engine
    self.layers = layers
    //    self.brushStyle = brushStyle
    self.catmullSteps = catmullSteps
  }

  public var body: some View {
    Canvas(
      opaque: true,
//      rendersAsynchronously: true,
    ) {
      context,
      size in

      let bgRect = CGRect(origin: .zero, size: size)
      context.fill(Path(bgRect), with: .color(.black))

      for layer in layers {
        renderLayer(layer, in: context)
      }

      for (_, stroke) in engine.activeStrokes {
        renderStroke(
          for: .active,
          points: stroke.points,
          touchOrder: stroke.touchOrder,
          in: context,
        )
      }

//      context.drawGrid(
//        domain: .automatic,
//        in: size,
//      )
    }
//    .environment(\.unitSize, CGSize(30, 40))
//    .environment(\.gridDimensions, .init(40, 20))
//    .environment(\.gridLineColour, .orange)
  }
}

extension DrawingCanvas {

  private func renderLayer(
    _ layer: any DrawingLayer,
    in context: GraphicsContext,
  ) {
    guard layer.metadata.isVisible else { return }
    for stroke in layer.filteredStrokes(using: .distance(minSeparation: 6)) {
      renderStroke(
        for: .completed(stroke.style),
        points: stroke.points,
        touchOrder: stroke.touchOrder,
        in: context,
      )
    }
  }

  private func renderStroke(
    for phase: StrokePhase,
    points: [StrokePoint],
    touchOrder: Int,

    in context: GraphicsContext,
  ) {
    guard points.count >= 2 else { return }

    let placeholderColour: Color = .gray
    let opacity = phase.isActive ? 0.6 : 1.0
    let style = phase.style ?? engine.brushStyle

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
