//
//  Representable.swift
//  LilyPad
//
//  Created by Dave Coleman on 3/5/2025.
//

#if canImport(AppKit)
import SwiftUI

/// Callback signature for receiving ordered touch updates.
/// Touches are sorted by the order each finger first made contact.
public typealias TouchesUpdate = ([TouchPoint]) -> Void

/// NSViewRepresentable bridge that hosts ``TrackpadTouchesNSView``
/// inside a SwiftUI view hierarchy.
struct TrackpadTouchesView: NSViewRepresentable {
//  var isActive: Bool
  var didUpdateTouches: TouchesUpdate

  func makeNSView(context: Context) -> TrackpadTouchesNSView {
    TrackpadTouchesNSView(didUpdateTouches)
  }

  func updateNSView(_ nsView: TrackpadTouchesNSView, context: Context) {
//    nsView.onTouchesChanged = didUpdateTouches
//    if isActive {
      /// Reclaim first responder whenever mode activates, ensuring
      /// touches route here even after a toolbar click stole focus.
//      DispatchQueue.main.async {
//        nsView.claimFocus()
//      }
//    }
  }
}
#endif
