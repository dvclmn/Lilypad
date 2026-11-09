//
//  TrackpadTouchesModifier.swift
//  Lilypad
//
//  Created by Dave Coleman on 7/5/2025.
//

import SwiftUI

/// Capture has no dependency on destination geometry or presentation.
struct TrackpadTouchesModifier: ViewModifier {
  let isEnabled: Bool
  let action: TouchesUpdate

  func body(content: Content) -> some View {
    content.overlay {
      if isEnabled {
        TrackpadTouchesView(didUpdateTouches: action)
      }
    }
  }
}
