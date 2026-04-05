//
//  TouchesNSView.swift
//  LilyPad
//
//  Created by Dave Coleman on 3/5/2025.
//

import AppKit

/// AppKit `NSView` that captures raw trackpad touch events and forwards
/// them through ``TrackpadTouchManager`` for processing.
///
/// Configured to receive indirect touches (trackpad, not Magic Mouse)
/// including resting/stationary fingers.
class TrackpadTouchesNSView: NSView {
  var onTouchesChanged: TouchesUpdate

  private let touchManager = TrackpadTouchManager()

  init(_ onTouchesChanged: @escaping TouchesUpdate) {
    self.onTouchesChanged = onTouchesChanged
    super.init(frame: .zero)
    allowedTouchTypes = [.indirect]
    wantsRestingTouches = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension TrackpadTouchesNSView {

  override var acceptsFirstResponder: Bool { true }

  /// Reclaim first responder so trackpad touches route here.
  func claimFocus() {
    guard window?.firstResponder !== self else { return }
    window?.makeFirstResponder(self)
  }

  private func processTouches(with event: NSEvent) {
    let touches = touchManager.processTouches(
      event.allTouches(),
      timestamp: event.timestamp,
    )
    onTouchesChanged(touches)
  }

  override func touchesBegan(with event: NSEvent) { processTouches(with: event) }
  override func touchesMoved(with event: NSEvent) { processTouches(with: event) }
  override func touchesEnded(with event: NSEvent) { processTouches(with: event) }
  override func touchesCancelled(with event: NSEvent) { processTouches(with: event) }
  //  override func pressureChange(with event: NSEvent) {
  //  }
}
