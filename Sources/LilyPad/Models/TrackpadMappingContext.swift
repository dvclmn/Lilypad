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
  func mappedSize(
    in viewportRect: CGRect,
    aspectRatio: CGFloat = CGSize.trackpadAspectRatio,
  ) -> TrackpadMappedRect? {
    .makeRect(
      in: viewportRect.size,
      mapping: mapping,
      sourceAspectRatio: CGSize.trackpadAspectRatio,
    )
  }
}
