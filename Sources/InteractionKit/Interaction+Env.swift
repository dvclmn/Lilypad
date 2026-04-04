//
//  Interaction+Env.swift
//  InteractionKit
//
//  Created by Dave Coleman on 28/3/2026.
//

import SwiftUI

extension EnvironmentValues {

  @Entry public var modifierKeys: Modifiers = []

  @Entry public var panOffset: Size<ScreenSpace> = .zero
  @Entry public var rotation: Angle = .zero

  /// Important: This zoom level is not clamped. Use ``zoomClamped``
  /// which clamps by ``zoomRange`` if clamping is required

  @Entry public var zoomLevel: Double = 1.0
  @Entry public var zoomRange: ClosedRange<Double>?

  /// Will return unclamped if no zoom range found in the Environment
  public var zoomClamped: Double {
    guard zoomLevel.isFiniteAndGreaterThanZero else { return 1.0 }
    return zoomLevel.clampedIfNeeded(to: zoomRange)
  }

  @Entry public var pointerStyle: PointerStyleCompatible?

  /// Aka artwork/document size. Used internally by CanvasKit only
  @Entry package var canvasSize: Size<CanvasSpace>?

  /// Captured by SwiftUI Anchor preference key. The rect origin expresses
  /// the `panOffset` (from the top left), and the rect size expresses
  /// the `canvasSize` scaled by the current `zoomLevel`
  @Entry public var artworkFrameInViewport: Rect<ScreenSpace>?

  /// The hover location in resolved CanvasSpace (before pan/zoom)
  @Entry public var pointerLocation: Point<CanvasSpace>?
  @Entry public var pointerTap: Point<CanvasSpace>?
  @Entry public var pointerDrag: Rect<CanvasSpace>?

  @Entry public var interactionPhase: InteractionPhase = .none
}
