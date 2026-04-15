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
  /// Rect in screen space
  public let rect: CGRect
  let scale: CGFloat
  let aspectRatio: CGFloat

  public init(
    rect: CGRect,
    scale: CGFloat,
    aspectRatio: CGFloat,
  ) {
    self.rect = rect
    self.scale = scale
    self.aspectRatio = aspectRatio
  }

  //  public init(
  //    origin: Point<ScreenSpace>,
  //    size: Size<ScreenSpace>,
  //    scale: CGFloat,
  //    aspectRatio: CGFloat
  //  ) {
  //    self.rect = .init(origin: origin, size: size)
  //    self.scale = scale
  //    self.aspectRatio = aspectRatio
  //  }
  //}
  //    public let origin: CGPoint
  //  public let size: CGSize
  //  public let scale: CGFloat
  //
  //
  //
  //
  //  // This never used the above `scale`?
  //  //  public var rect: CGRect {
  //  //    CGRect(origin: origin, size: size)
  //  //  }
}

extension TrackpadMappedRect {

  /// Computes the rectangle within the view that the trackpad maps onto.
  /// `viewSize` is expected to be in screen (viewport) space,
  /// not local canvas/artwork/document space.
  public static func makeRect(
    in viewSize: CGSize,
    mapping: TouchMapping,
    sourceAspectRatio: CGFloat = CGSize.trackpadAspectRatio,
  ) -> TrackpadMappedRect? {
    //  ) -> Rect<ScreenSpace>? {
    //  ) -> Size<ScreenSpace>? {
    guard viewSize.width > 0, viewSize.height > 0 else { return nil }

    switch mapping {
      case .normalised:
        let rect = CGRect(origin: .zero, size: viewSize)
        return .init(
          rect: rect,
          //          origin: .zero,
          //          size: viewSize,
          scale: 1,
          aspectRatio: sourceAspectRatio,
        )
      //        return .init(width: viewSize.width, height: <#T##CGFloat#>)
      //        return TrackpadMappedRect(
      //          origin: .zero,
      //          size: viewSize.cgSize,
      //          scale: 1,
      //        )

      case .fit, .fill:
        let sourceWidth: CGFloat = 1.0
        let sourceHeight: CGFloat = sourceAspectRatio

        let scale: CGFloat =
          switch mapping {
            case .fit: min(viewSize.width / sourceWidth, viewSize.height / sourceHeight)
            case .fill: max(viewSize.width / sourceWidth, viewSize.height / sourceHeight)
            default: 1
          }

        let scaledWidth = sourceWidth * scale
        let scaledHeight = sourceHeight * scale
        let offsetX = (viewSize.width - scaledWidth) / 2
        let offsetY = (viewSize.height - scaledHeight) / 2

        let origin = CGPoint(x: offsetX, y: offsetY)
        //        let origin = Point<ScreenSpace>(x: offsetX, y: offsetY)
        let size = CGSize(width: scaledWidth, height: scaledHeight)
        //        let size = Size<ScreenSpace>(width: scaledWidth, height: scaledHeight)
        return .init(
          rect: CGRect(origin: origin, size: size),
          //          origin: origin,
          //          size: size,
          scale: scale,
          aspectRatio: sourceAspectRatio,
        )
    //        return .init(width: scaledWidth, height: scaledHeight)
    //        return TrackpadMappedRect(
    //          origin: CGPoint(x: offsetX, y: offsetY),
    //          size: CGSize(width: scaledWidth, height: scaledHeight),
    //          scale: scale,
    //        )
    }
  }

}
