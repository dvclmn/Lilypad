//
//  TrackpadMappedRect.swift
//  InteractionKit
//
//  Created by Dave Coleman on 6/4/2026.
//

import Foundation
import InteractionKit

/// The rectangle within the view where trackpad touches are mapped to.
///
/// Computed by fitting (or filling) the trackpad’s aspect ratio into
/// the target view size. Use this to render a visual guide showing
/// exactly where trackpad touches will land.
public struct TrackpadMappedRect: Equatable, Sendable {
  public let origin: CGPoint
  public let size: CGSize
  public let scale: CGFloat
  
  public var rect: CGRect {
    CGRect(origin: origin, size: size)
  }
}

extension TrackpadMappedRect {
  
  /// Computes the rectangle within the view that the trackpad maps onto.
  public static func makeRect(
    in viewSize: Size<CanvasSpace>,
    mapping: TouchMapping,
    sourceAspectRatio: CGFloat = CGSize.trackpadAspectRatio
  ) -> Self? {
    guard viewSize.width > 0, viewSize.height > 0 else { return nil }
    
    switch mapping {
      case .normalised:
        return TrackpadMappedRect(
          origin: .zero,
          size: viewSize.cgSize,
          scale: 1
        )
        
      case .fit, .fill:
        let sourceWidth: CGFloat = 1.0
        let sourceHeight: CGFloat = sourceAspectRatio
        
        let scale: CGFloat = switch mapping {
          case .fit: min(viewSize.width / sourceWidth, viewSize.height / sourceHeight)
          case .fill: max(viewSize.width / sourceWidth, viewSize.height / sourceHeight)
          default: 1
        }
        
        let scaledWidth = sourceWidth * scale
        let scaledHeight = sourceHeight * scale
        let offsetX = (viewSize.width - scaledWidth) / 2
        let offsetY = (viewSize.height - scaledHeight) / 2
        
        return TrackpadMappedRect(
          origin: CGPoint(x: offsetX, y: offsetY),
          size: CGSize(width: scaledWidth, height: scaledHeight),
          scale: scale
        )
    }
  }

}
