//
//  Environment.swift
//  InteractionKit
//
//  Created by Dave Coleman on 30/3/2026.
//

import SwiftUI

extension EnvironmentValues {

  /// Aka artwork size, document size
//  @Entry public var canvasSize: Size<CanvasSpace>?
//  @Entry public var artworkFrameInViewport: Rect<ScreenSpace>?

  /// The hover location in resolved CanvasSpace (before pan/zoom)
  @Entry public var pointerLocation: CGPoint?

}
