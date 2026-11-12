//
//  TrackpadMapping.swift
//  Lilypad
//
//  Created by Dave Coleman on 10/11/2026.
//

import CoreGraphics

/// An immutable mapping from bottom-left normalised trackpad coordinates into
/// a caller-chosen rectangle with a top-left origin and downward-positive Y.
///
/// The caller owns the destination's units and meaning. No view measurement,
/// clipping, capture or artwork policy is performed here. Use the same value
/// for input and its guide. Source size supplies proportions, not output units.
public struct TrackpadMapping: Equatable, Sendable {
  public let destination: CGRect
  public let scaling: TouchMapping

  /// The bounds reached by the whole source surface. May extend outside
  /// `destination` for `.fill`. Its origin is significant when drawing a guide.
  public let mappedRect: CGRect

  /// The resolved transform, including the Y reflection and destination offset.
  public var transform: CGAffineTransform {
    CGAffineTransform(
      a: mappedRect.width, b: 0, c: 0, d: -mappedRect.height,
      tx: mappedRect.minX, ty: mappedRect.maxY
    )
  }

  /// Resolve centred fit/fill, or corner-to-corner stretch.
  ///
  /// Fit/fill require finite, positive source dimensions. Stretch needs no
  /// source geometry. There is deliberately no assumed hardware aspect ratio.
  /// Invalid, empty, overflowing or numerically collapsed geometry returns nil.
  public init?(
    sourceSize: CGSize? = nil,
    destination: CGRect,
    scaling: TouchMapping = .fit
  ) {
    guard destination.origin.x.isFinite, destination.origin.y.isFinite,
      destination.size.width.isFinite, destination.size.height.isFinite,
      destination.size.width > 0, destination.size.height > 0,
      destination.maxX.isFinite, destination.maxY.isFinite,
      destination.maxX > destination.minX, destination.maxY > destination.minY
    else { return nil }

    let size: CGSize
    switch scaling {
      case .stretch:
        size = destination.size
      case .fit, .fill:
        guard let sourceSize = validatedTouchDeviceSize(sourceSize) else { return nil }
        // Normalising by the larger source dimension avoids unnecessary
        // overflow when the supplied physical dimensions are very large.
        let longest = max(sourceSize.width, sourceSize.height)
        let width = sourceSize.width / longest
        let height = sourceSize.height / longest
        let xScale = destination.width / width
        let yScale = destination.height / height
        let scale = scaling == .fit ? min(xScale, yScale) : max(xScale, yScale)
        size = CGSize(width: width * scale, height: height * scale)
    }
    guard size.width.isFinite, size.height.isFinite,
      size.width > 0, size.height > 0 else { return nil }
    let rect = CGRect(
      x: destination.minX + (destination.width - size.width) / 2,
      y: destination.minY + (destination.height - size.height) / 2,
      width: size.width, height: size.height
    )
    guard rect.minX.isFinite, rect.minY.isFinite,
      rect.maxX.isFinite, rect.maxY.isFinite,
      rect.maxX > rect.minX, rect.maxY > rect.minY else { return nil }
    self.destination = destination
    self.scaling = scaling
    self.mappedRect = rect
  }

  /// Maps a position without clipping it to the destination.
  public func position(from normalisedPosition: CGPoint) -> CGPoint {
    normalisedPosition.applying(transform)
  }

  /// Maps finger velocity into destination units per second. Translation is
  /// excluded: moving the destination must not add speed to a stationary finger.
  public func velocity(from normalisedVelocity: CGVector) -> CGVector {
    CGVector(dx: normalisedVelocity.dx * mappedRect.width,
             dy: -normalisedVelocity.dy * mappedRect.height)
  }

  public func map(_ touch: TouchPoint) -> MappedTouchPoint {
    MappedTouchPoint(
      source: touch,
      position: position(from: touch.position),
      velocity: velocity(from: touch.velocity)
    )
  }

}
