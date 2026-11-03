//
//  TrackpadMappingContext.swift
//  Lilypad
//
//  Created by Dave Coleman on 20/4/2026.
//

import Foundation

struct TrackpadMappingContext {
  let guide: TrackpadGuideVisibility
  let mode: TrackpadMode
  let mapping: TouchMapping
}

extension TrackpadMappingContext {
  /// Mapping uses local viewport coordinates, independent of the viewport's
  /// origin in a parent, window or screen coordinate space.
  func mappedSize(
    in viewportSize: CGSize,
    aspectRatio: CGFloat = CGSize.trackpadAspectRatio,
  ) -> TrackpadMappedRect? {
    .makeRect(
      in: viewportSize,
      mapping: mapping,
      sourceAspectRatio: aspectRatio,
    )
  }
}
