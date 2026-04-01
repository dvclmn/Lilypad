//
//  CatmullRom.swift
//  LilyPad
//

import SwiftUI

/// Catmull-Rom spline interpolation for smooth curve generation.
///
/// Catmull-Rom splines pass through every control point, making them ideal
/// for drawing applications where captured touch points should lie exactly
/// on the rendered curve.
///
/// ## Choosing a variant
///
/// - `.centripetal` (α = 0.5): Recommended default. Prevents cusps and
///   self-intersections, produces natural-feeling curves.
/// - `.uniform` (α = 0): Standard formulation, fastest to compute.
/// - `.chordal` (α = 1): Follows the path more loosely; can look overly
///   relaxed on sharp direction changes.
///
public enum CatmullRom {

  // MARK: - Point evaluation

  /// Evaluates a single point on the segment from `p1` to `p2`.
  ///
  /// Requires one phantom point on each side (`p0` before `p1`, `p3` after
  /// `p2`) to define the tangent at the endpoints. For the first and last
  /// segments, duplicate the nearest endpoint.
  ///
  /// - Parameter t: Position along the segment, 0 = `p1`, 1 = `p2`.
  public static func point(
    p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint,
    t: CGFloat,
    variant: Variant = .centripetal
  ) -> CGPoint {
    if variant == .uniform {
      return uniformBasis(p0: p0, p1: p1, p2: p2, p3: p3, t: t)
    }

    let alpha = variant.alpha
    let t0: CGFloat = 0
    let t1 = knot(t0, p0, p1, alpha: alpha)
    let t2 = knot(t1, p1, p2, alpha: alpha)
    let t3 = knot(t2, p2, p3, alpha: alpha)

    let tt = t1 + (t2 - t1) * t

    let a1 = blend(p0, p1, lo: t0, hi: t1, at: tt)
    let a2 = blend(p1, p2, lo: t1, hi: t2, at: tt)
    let a3 = blend(p2, p3, lo: t2, hi: t3, at: tt)

    let b1 = blend(a1, a2, lo: t0, hi: t2, at: tt)
    let b2 = blend(a2, a3, lo: t1, hi: t3, at: tt)

    return blend(b1, b2, lo: t1, hi: t2, at: tt)
  }

  /// Evaluates a scalar value using Catmull-Rom interpolation.
  ///
  /// Use this alongside ``point(p0:p1:p2:p3:t:variant:)`` to interpolate
  /// associated per-point data (e.g. stroke speed → line width) at the same
  /// parameter values, keeping the width in sync with the curve.
  public static func scalar(
    v0: CGFloat, v1: CGFloat, v2: CGFloat, v3: CGFloat,
    t: CGFloat,
    variant: Variant = .centripetal
  ) -> CGFloat {
    if variant == .uniform {
      let t2 = t * t, t3 = t2 * t
      return 0.5 * (2 * v1 + (-v0 + v2) * t + (2 * v0 - 5 * v1 + 4 * v2 - v3) * t2 + (-v0 + 3 * v1 - 3 * v2 + v3) * t3)
    }
    // Reuse the point evaluator via a 1D trick
    let p = point(
      p0: CGPoint(x: v0, y: 0), p1: CGPoint(x: v1, y: 0),
      p2: CGPoint(x: v2, y: 0), p3: CGPoint(x: v3, y: 0),
      t: t, variant: variant
    )
    return p.x
  }

  // MARK: - Cubic Bézier conversion

  /// Converts a Catmull-Rom segment to its equivalent cubic Bézier handles.
  ///
  /// This is the most efficient way to draw a Catmull-Rom spine using
  /// SwiftUI's `Path.addCurve(to:control1:control2:)`, since the renderer
  /// handles subdivision internally.
  ///
  /// - Returns: The two cubic Bézier control points for the p1→p2 segment.
  public static func toCubicBezier(
    p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint,
    variant: Variant = .centripetal
  ) -> (c1: CGPoint, c2: CGPoint) {
    let alpha = variant.alpha

    let d1 = distance(p0, p1), d2 = distance(p1, p2), d3 = distance(p2, p3)
    let d1a = pow(d1, alpha), d2a = pow(d2, alpha), d3a = pow(d3, alpha)

    guard d1a + d2a > 0, d2a + d3a > 0 else { return (c1: p1, c2: p2) }

    let c1 = CGPoint(
      x: p1.x + (p2.x - p0.x) * d2a / (3 * (d1a + d2a)),
      y: p1.y + (p2.y - p0.y) * d2a / (3 * (d1a + d2a))
    )
    let c2 = CGPoint(
      x: p2.x - (p3.x - p1.x) * d2a / (3 * (d2a + d3a)),
      y: p2.y - (p3.y - p1.y) * d2a / (3 * (d2a + d3a))
    )
    return (c1, c2)
  }

  // MARK: - Convenience: smooth a point array

  /// Returns a `Path` that smoothly passes through all points via
  /// Catmull-Rom cubic Bézier conversion.
  ///
  /// Fewer than 2 points returns an empty path. 2 points returns a straight
  /// line. 3+ points produces a smooth spline.
  public static func path(
    through points: [CGPoint],
    variant: Variant = .centripetal,
    closed: Bool = false
  ) -> Path {
    guard points.count >= 2 else { return Path() }

    return Path { p in
      p.move(to: points[0])

      let n = points.count
      for i in 0..<(n - 1) {
        let p0 = points[max(0, i - 1)]
        let p1 = points[i]
        let p2 = points[i + 1]
        let p3 = points[min(n - 1, i + 2)]

        let (c1, c2) = toCubicBezier(p0: p0, p1: p1, p2: p2, p3: p3, variant: variant)
        p.addCurve(to: p2, control1: c1, control2: c2)
      }

      if closed { p.closeSubpath() }
    }
  }

  /// Samples `steps` evenly-spaced points along each segment, returning a
  /// denser array of `(position, interpolatedValue)` pairs.
  ///
  /// Use this when you need explicit point positions — for example when
  /// feeding into ``VariableWidthPath`` to build a filled outline.
  ///
  /// - Parameters:
  ///   - positions: Control point positions.
  ///   - values: Scalar values associated with each control point
  ///     (e.g. speed). Must be the same length as `positions`.
  ///   - steps: Subdivisions per segment. 6–12 is usually sufficient.
  public static func sample(
    positions: [CGPoint],
    values: [CGFloat],
    steps: Int = 8,
    variant: Variant = .centripetal
  ) -> [(position: CGPoint, value: CGFloat)] {
    let n = positions.count
    guard n >= 2, values.count == n else {
      return zip(positions, values).map { ($0, $1) }
    }

    var result: [(CGPoint, CGFloat)] = []
    result.reserveCapacity((n - 1) * steps + 1)

    for i in 0..<(n - 1) {
      let i0 = max(0, i - 1), i1 = i, i2 = i + 1, i3 = min(n - 1, i + 2)

      for step in 0..<steps {
        let t = CGFloat(step) / CGFloat(steps)
        let pt = point(p0: positions[i0], p1: positions[i1], p2: positions[i2], p3: positions[i3], t: t, variant: variant)
        let v = scalar(v0: values[i0], v1: values[i1], v2: values[i2], v3: values[i3], t: t, variant: variant)
        result.append((pt, v))
      }
    }

    result.append((positions[n - 1], values[n - 1]))
    return result
  }

  // MARK: - Private

  private static func uniformBasis(
    p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, t: CGFloat
  ) -> CGPoint {
    let t2 = t * t, t3 = t2 * t
    let b0 = -0.5 * t3 + t2 - 0.5 * t
    let b1 =  1.5 * t3 - 2.5 * t2 + 1.0
    let b2 = -1.5 * t3 + 2.0 * t2 + 0.5 * t
    let b3 =  0.5 * t3 - 0.5 * t2
    return CGPoint(
      x: b0 * p0.x + b1 * p1.x + b2 * p2.x + b3 * p3.x,
      y: b0 * p0.y + b1 * p1.y + b2 * p2.y + b3 * p3.y
    )
  }

  private static func knot(_ ti: CGFloat, _ pi: CGPoint, _ pj: CGPoint, alpha: CGFloat) -> CGFloat {
    ti + pow(distance(pi, pj), alpha)
  }

  /// Linearly blends two points at parameter `at` within the range [lo, hi].
  private static func blend(_ a: CGPoint, _ b: CGPoint, lo: CGFloat, hi: CGFloat, at t: CGFloat) -> CGPoint {
    guard hi > lo else { return a }
    let w = (t - lo) / (hi - lo)
    return CGPoint(x: a.x + (b.x - a.x) * w, y: a.y + (b.y - a.y) * w)
  }

  private static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    hypot(b.x - a.x, b.y - a.y)
  }
}
