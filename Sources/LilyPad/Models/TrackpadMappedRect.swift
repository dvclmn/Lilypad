//
//  TrackpadMappedRect.swift
//  InteractionKit
//
//  Created by Dave Coleman on 6/4/2026.
//

import Foundation

//import InteractionKit

/// The rectangle within the view where trackpad touches are mapped to.
///
/// Computed by fitting (or filling) the trackpad’s aspect ratio into
/// the target view size. Use this to render a visual guide showing
/// exactly where trackpad touches will land.
public struct TrackpadMappedRect: Equatable, Sendable {

  /// Rectangle in local viewport coordinates.
  public let rect: CGRect
  let scale: CGFloat
  let aspectRatio: CGFloat

  /// Creates an explicit mapping. The caller must supply finite geometry, a
  /// positive scale and aspect ratio, and a rect size matching that transform.
  /// Prefer `makeRect(in:mapping:sourceAspectRatio:)` for validated layout input.
  public init(
    rect: CGRect,
    scale: CGFloat,
    aspectRatio: CGFloat,
  ) {
    self.rect = rect
    self.scale = scale
    self.aspectRatio = aspectRatio
  }
}

extension TrackpadMappedRect {

  /// Computes the rectangle within the view that the trackpad maps onto.
  /// `viewSize` is expected to be in screen (viewport) space,
  /// not local canvas/artwork/document space. The result has a local viewport
  /// origin; no parent/window origin is applied. Invalid or unrepresentable
  /// geometry returns `nil`. For `.normalised`, the rect describes the viewport
  /// guide only; touch positions and velocities remain untouched.
  public static func makeRect(
    in viewSize: CGSize,
    mapping: TouchMapping,
    sourceAspectRatio: CGFloat = CGSize.trackpadAspectRatio,
  ) -> TrackpadMappedRect? {

    guard viewSize.width.isFinite, viewSize.height.isFinite,
      viewSize.width > 0, viewSize.height > 0,
      sourceAspectRatio.isFinite, sourceAspectRatio > 0
    else { return nil }

    switch mapping {
      case .normalised:
        return .init(
          rect: .init(origin: .zero, size: viewSize),
          scale: 1,
          aspectRatio: sourceAspectRatio,
        )

      case .fit, .fill:
        let sourceWidth: CGFloat = 1.0
        let sourceHeight: CGFloat = sourceAspectRatio

        let scale: CGFloat =
          switch mapping {
            case .fit: min(viewSize.width / sourceWidth, viewSize.height / sourceHeight)
            case .fill: max(viewSize.width / sourceWidth, viewSize.height / sourceHeight)
            case .normalised: 1
          }

        let scaledWidth = sourceWidth * scale
        let scaledHeight = sourceHeight * scale
        guard scale.isFinite, scale > 0,
          scaledWidth.isFinite, scaledHeight.isFinite,
          scaledWidth > 0, scaledHeight > 0
        else { return nil }
        let offsetX = (viewSize.width - scaledWidth) / 2
        let offsetY = (viewSize.height - scaledHeight) / 2

        let origin = CGPoint(x: offsetX, y: offsetY)
        let size = CGSize(width: scaledWidth, height: scaledHeight)

        return .init(
          rect: CGRect(origin: origin, size: size),
          scale: scale,
          aspectRatio: sourceAspectRatio,
        )

    }
  }

}
