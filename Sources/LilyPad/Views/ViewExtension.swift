//
//  ViewExtension.swift
//  InteractionKit
//
//  Created by Dave Coleman on 6/4/2026.
//

import SwiftUI

extension View {

  /// Captures trackpad multi-touch input and delivers ordered touch updates.
  ///
  /// This modifier overlays trackpad touch capture on your view, transforming raw
  /// trackpad coordinates into your canvas coordinate space according to the specified
  /// mapping strategy. Touch positions are delivered with stable ordering based on
  /// the sequence fingers made contact.
  ///
  /// - Parameters:
  ///   - canvasSize: The size of your target canvas or drawing area. Touch coordinates
  ///     will be mapped into this coordinate space.
  ///   - mapping: How trackpad coordinates map to the canvas. Options:
  ///     - `.fit` (default): Scales uniformly to fit the trackpad's aspect ratio within
  ///       the canvas, adding letterboxing if needed. Guarantees all touches stay in bounds.
  ///     - `.fill`: Scales uniformly to fill the canvas, cropping the trackpad area if needed.
  ///     - `.normalised`: Raw 0–1 normalized coordinates with no transformation.
  ///   - mode: Controls trackpad capture behaviour:
  ///     - `.active`: Captures touches with standard pointer behaviour.
  ///     - `.activePointerHidden`: Captures touches and hides the pointer to prevent
  ///       accidental clicks or focus loss.
  ///     - `.inactive` (default): Disables touch capture entirely.
  ///   - trackpadMatchesZoom: When `true`, the trackpad mapping adjusts to match
  ///     canvas zoom level (implementation defined by your view's zoom state).
  ///   - guideVisibility: Controls when the visual trackpad mapping guide appears:
  ///     - `.always` (default): Guide always visible.
  ///     - `.drawingMode`: Guide visible only when `mode` is enabled (`.active` or `.activePointerHidden`).
  ///     - `.never`: Guide never visible.
  ///   - showsTouchIndicators: When `true` (default), displays numbered overlays showing
  ///     each finger's position and touch order.
  ///   - action: Called each time touches change, receiving an array of ``TouchPoint``
  ///     values sorted by first-contact order (finger 1, finger 2, etc.). Touch positions
  ///     are in canvas coordinate space as specified by `canvasSize` and `mapping`.
  public func trackpadTouches(
    canvasSize: CGSize,
    mapping: TouchMapping = .fit,
    mode: TrackpadMode = .inactive,
//    trackpadMatchesZoom: Bool,
    guideVisibility: TrackpadGuideVisibility = .always,
    showsTouchIndicators: Bool = true,
    perform action: @escaping ([TouchPoint], TrackpadMappedRect) -> Void,
  ) -> some View {
    self.modifier(
      TrackpadTouchesModifier(
        canvasSize: canvasSize,
        //        canvasSize: .init(fromCGSize: canvasSize),
        mapping: mapping,
        trackpadMode: mode,
//        trackpadMatchesZoom: trackpadMatchesZoom,
        guideVisibility: guideVisibility,
        showsTouchIndicators: showsTouchIndicators,
        action: action,
      )
    )
  }
}
