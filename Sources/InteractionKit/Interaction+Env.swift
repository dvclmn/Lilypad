//
//  Interaction+Env.swift
//  InteractionKit
//
//  Created by Dave Coleman on 28/3/2026.
//

import SwiftUI

extension EnvironmentValues {

  @Entry public var modifierKeys: Modifiers = []
  
  @Entry public var panOffset: CGSize = .zero
  @Entry public var rotation: Angle = .zero

  @Entry public var zoomLevel: Double = 1.0
  @Entry public var zoomRange: ClosedRange<Double>?

  /// Will return unclamped if no zoom range found in the Environment
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndGreaterThanZero else { return 1.0 }
    return zoomLevel.clampedIfNeeded(to: zoomRange)
  }

  @Entry public var pointerStyle: PointerStyleCompatible?

  /// Aka artwork size, document size
  //  @Entry public var canvasSize: Size<CanvasSpace>?
  
  /// Captured by SwiftUI Anchor preference key. The rect origin expresses
  /// the `panOffset` (from the top left), and the rect size expresses
  /// the `canvasSize` scaled by the current `zoomLevel`
  @Entry public var artworkFrameInViewport: Rect<ScreenSpace>?
  
  public var coordinateSpaceMapper: CoordinateSpaceMapper? {
    guard let artworkFrameInViewport, let zoomRange else { return nil }
    return .init(
      artworkFrame: artworkFrameInViewport,
      zoom: zoomLevel,
      //      zoom: transform.scale,
      zoomRange: zoomRange,
    )
  }
  //  @Entry public var coordinateSpaceMapper: CoordinateSpaceMapper?

  /// The hover location in resolved CanvasSpace (before pan/zoom)
  @Entry public var pointerLocation: Point<CanvasSpace>?
  @Entry public var pointerDrag: Rect<ScreenSpace>?
//  @Entry public var pointerLocation: CGPoint?

}
