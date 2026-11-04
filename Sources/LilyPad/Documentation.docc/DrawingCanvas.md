# DrawingCanvas

Renders strokes from a ``StrokeEngine`` using SwiftUI Canvas.

Both active (in-progress) and completed strokes are drawn.


## Rendering pipeline

For each stroke (active or completed):

1. **Catmull-Rom sampling** — the raw captured points are densified using
Catmull-Rom interpolation. Positions *and* speed values are interpolated
together, so the width follows the actual curve, not just the control points.

2. **Width mapping** — each sampled point's speed is passed through
``StrokeWidthProfile/width(for:)`` to get a line width. Slower = wider.

3. **Variable-width fill** — a ``VariableWidthPath`` accumulates left/right
edge offsets and generates a filled outline path.

4. **Canvas fill** — the filled path is drawn with `context.fill()`.


To do:

- **Vary width by speed**: Use each `StrokePoint.speed` to interpolate
  between a min/max width — faster movement → thinner line.

- **Curve interpolation**: Replace `addLine(to:)` segments with
  Catmull-Rom splines or cubic Béziers for smoother curves.

- **Offscreen compositing**: For many strokes, render completed strokes
  to a `CGImage` and only redraw active strokes each frame.

- **Brush textures**: Stamp a brush image along the path instead of
  stroking a geometric path.


## Customising

- Swap in a different ``StrokeWidthProfile`` to change the speed-to-width mapping.
- Adjust ``catmullSteps`` to trade smoothness for performance.
- Replace the fill call with a texture stamp or blend mode for richer effects.

