//
//  VariableWidthPath.swift
//  LilyPad
//

import SwiftUI

/// Builds a filled `Path` representing a stroke with per-point width variation.
///
/// Feed points one at a time via ``addPoint(to:rawWidth:)``, then call
/// ``generatePath(usesSmoothCurves:)`` to get a filled SwiftUI `Path`.
///
/// ## How it works
///
/// At each point, a perpendicular normal is computed from the direction of
/// travel. The point is offset left and right by `width / 2` along that
/// normal, building two parallel edge arrays. The final path traces the
/// left edge forward, then the right edge backward, forming a closed outline.
///
/// Normal smoothing (75/25 blend with the previous normal) prevents
/// jitter on slightly noisy input. Sharp direction changes are handled by
/// reducing width at the corner to avoid crossing edges.
///
/// ## Usage
///
/// ```swift
/// var vwp = VariableWidthPath()
/// for point in denseSampledPoints {
///   vwp.addPoint(to: point.position, rawWidth: brushStyle.width(for: point.speed))
/// }
/// let path = vwp.generatePath(usesSmoothCurves: true)
/// context.fill(path, with: .color(colour))
/// ```
///
public struct VariableWidthPath {
  var leftEdge: [CGPoint] = []
  var rightEdge: [CGPoint] = []

  private var pendingFirstPoint: CGPoint?
  private var previousNormal: CGPoint?
  private var previousWidth: CGFloat?

  public init() {}

  // MARK: - Building

  /// Append a point to the stroke outline with the given width.
  ///
  /// Width is smoothed against the previous value (85/15 blend) to avoid
  /// sudden jumps from noisy velocity readings.
  public mutating func addPoint(to current: CGPoint, rawWidth: CGFloat) {
    // Smooth width against previous
    let width: CGFloat
    if let prev = previousWidth {
      width = prev * 0.85 + rawWidth * 0.15
    } else {
      width = rawWidth
    }
    previousWidth = width

    // Buffer the very first point — we need two points to compute a direction
    guard pendingFirstPoint != nil || !leftEdge.isEmpty else {
      pendingFirstPoint = current
      return
    }

    let from: CGPoint
    if let pending = pendingFirstPoint {
      from = pending
      pendingFirstPoint = nil
    } else {
      from = leftEdge.last.map { pt in
        // Back-compute the spine position from the last left edge point and normal
        guard let n = previousNormal, let w = previousWidth else { return current }
        return CGPoint(x: pt.x - n.x * w / 2, y: pt.y - n.y * w / 2)
      } ?? current
    }

    if let (left, right, normal) = offsetEdges(from: from, to: current, width: width) {
      leftEdge.append(left)
      rightEdge.append(right)
      previousNormal = normal
    }
  }

  // MARK: - Path generation

  /// Generates the final filled `Path` from the accumulated edge points.
  ///
  /// - Parameter usesSmoothCurves: When `true`, edges are drawn with
  ///   quadratic curves through midpoints for a smoother silhouette.
  ///   When `false`, straight line segments are used (faster, fine for
  ///   high-density input).
  public func generatePath(usesSmoothCurves: Bool = true) -> Path {
    guard leftEdge.count == rightEdge.count, !leftEdge.isEmpty else {
      return fallbackPath
    }

    var path = Path()
    if usesSmoothCurves {
      buildSmoothPath(&path)
    } else {
      buildLinePath(&path)
    }
    return path
  }

  // MARK: - Private

  private var fallbackPath: Path {
    var path = Path()
    if let pt = leftEdge.first ?? rightEdge.first {
      path.addEllipse(in: CGRect(x: pt.x - 1, y: pt.y - 1, width: 2, height: 2))
    }
    return path
  }

  private func buildLinePath(_ path: inout Path) {
    path.move(to: leftEdge[0])
    for pt in leftEdge.dropFirst() { path.addLine(to: pt) }
    for pt in rightEdge.reversed() { path.addLine(to: pt) }
    path.closeSubpath()
  }

  private func buildSmoothPath(_ path: inout Path) {
    // Left edge — forward
    path.move(to: leftEdge[0])
    for i in 1..<leftEdge.count {
      let mid = CGPoint(
        x: (leftEdge[i - 1].x + leftEdge[i].x) / 2,
        y: (leftEdge[i - 1].y + leftEdge[i].y) / 2
      )
      path.addQuadCurve(to: mid, control: leftEdge[i - 1])
    }
    path.addLine(to: leftEdge.last!)

    // Right edge — reverse
    path.addLine(to: rightEdge.last!)
    for i in (1..<rightEdge.count).reversed() {
      let mid = CGPoint(
        x: (rightEdge[i].x + rightEdge[i - 1].x) / 2,
        y: (rightEdge[i].y + rightEdge[i - 1].y) / 2
      )
      path.addQuadCurve(to: mid, control: rightEdge[i])
    }
    path.addLine(to: rightEdge[0])
    path.closeSubpath()
  }

  /// Computes the left and right edge points for the segment from → to,
  /// with normal smoothing and sharp-corner width reduction.
  private mutating func offsetEdges(
    from: CGPoint,
    to current: CGPoint,
    width: CGFloat
  ) -> (left: CGPoint, right: CGPoint, normal: CGPoint)? {
    let dx = current.x - from.x
    let dy = current.y - from.y
    let len = hypot(dx, dy)
    guard len > 0 else { return nil }

    // Raw normal (perpendicular to direction of travel)
    let rawNormal = CGPoint(x: -dy / len, y: dx / len)

    // Smooth with previous normal to reduce jitter
    let normal: CGPoint
    if let prev = previousNormal {
      let bx = prev.x * 0.75 + rawNormal.x * 0.25
      let by = prev.y * 0.75 + rawNormal.y * 0.25
      let bl = hypot(bx, by)
      normal = CGPoint(x: bx / bl, y: by / bl)
    } else {
      normal = rawNormal
    }

    // Reduce width on sharp corners to prevent edge crossing
    let effectiveWidth: CGFloat
    if let prev = previousNormal {
      let dot = normal.x * prev.x + normal.y * prev.y
      effectiveWidth = dot < 0.1 ? width * 0.5 : width
    } else {
      effectiveWidth = width
    }

    let half = effectiveWidth / 2
    return (
      left:  CGPoint(x: current.x + normal.x * half, y: current.y + normal.y * half),
      right: CGPoint(x: current.x - normal.x * half, y: current.y - normal.y * half),
      normal: normal
    )
  }
}
