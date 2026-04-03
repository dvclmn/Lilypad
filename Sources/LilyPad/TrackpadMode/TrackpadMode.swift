//
//  TrackpadMode.swift
//  LilyPad
//
//  Created by Dave Coleman on 2025.
//

#if canImport(AppKit)
import AppKit
import SwiftUI

@MainActor
@Observable
public final class TrackpadMode {

  /// Whether drawing mode is currently active.
  /// Setting this to `true` hides and locks the cursor; `false` restores it.
  ///
  /// I may consider instead driving this via `onChange()` in the View
  /// rather than `didSet`; maybe more SwiftUI-like?
  public var isActive: Bool = false {
    didSet {
      guard isActive != oldValue else { return }
      if isActive { engage() } else { disengage() }
    }
  }

  // MARK: - Internal state

  /// Tracks whether `NSCursor.hide()` has been called — prevents stack imbalance.
  private var cursorIsHidden = false

  /// Tracks whether `CGAssociateMouseAndMouseCursorPosition(0)` has been called
  private var cursorIsLocked = false

  /// Cursor position saved when entering drawing mode, restored on exit.
  private var savedCursorPosition: CGPoint?

  /// Local event monitor for suppressing clicks.
  private var clickMonitor: Any?

  /// Observer for app deactivation (Cmd+Tab, clicking another app, etc.).
  private var deactivationObserver: NSObjectProtocol?

  /// Observer for app reactivation.
  private var activationObserver: NSObjectProtocol?

  /// Whether observers have been installed (done once via the modifier).
  private var observersInstalled = false

  /// Which pointer behaviours to apply when drawing mode is active.
  /// Defaults to all three: hide, lock, and click suppression.
  public var behaviours: Behaviours = .all

  public init(behaviours: Behaviours = .all) {
    self.behaviours = behaviours
  }

  /// Note: no deinit — cleanup is handled by `tearDown()`, which the
  /// `.trackpadMode(_:)` modifier calls on disappear. Always pair this
  /// class with `TrackpadModeModifier` to ensure correct cleanup.
}

// MARK: - Lifecycle (called by the modifier)

extension TrackpadMode {

  /// Install app activation observers. Called once when the modifier appears.
  func setUp() {
    guard !observersInstalled else { return }
    observersInstalled = true

    deactivationObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didResignActiveNotification,
      object: nil,
      queue: .main,
    ) { [weak self] _ in
      MainActor.assumeIsolated {
        self?.handleAppDeactivation()
      }
    }

    activationObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main,
    ) { [weak self] _ in
      MainActor.assumeIsolated {
        self?.handleAppActivation()
      }
    }
  }

  /// Remove observers and force-disengage. Called when the modifier disappears.
  func tearDown() {
    disengage()

    if let observer = deactivationObserver {
      NotificationCenter.default.removeObserver(observer)
      deactivationObserver = nil
    }
    if let observer = activationObserver {
      NotificationCenter.default.removeObserver(observer)
      activationObserver = nil
    }
    observersInstalled = false
  }
}

// MARK: - Engage / Disengage

extension TrackpadMode {

  private func engage() {
    /// Save current cursor position for restoration later.
    /// Note: `NSEvent.mouseLocation` is in screen coordinates, origin is bottom-left
    savedCursorPosition = screenCursorPosition()

    if behaviours.contains(.lock) {
      lockCursor()
    }

    if behaviours.contains(.hide) {
      hideCursor()
    }

    if behaviours.contains(.suppressClicks) {
      installClickMonitor()
    }
  }

  private func disengage() {
    removeClickMonitor()
    unlockCursor()
    showCursor()
    restoreCursorPosition()
  }
}

// MARK: - App activation

extension TrackpadMode {

  /// When the app loses focus, always disengage pointer control — the user
  /// needs their cursor back to interact with other apps. We don't clear
  /// `isActive` so we can re-engage when they return.
  private func handleAppDeactivation() {
    guard isActive else { return }
    removeClickMonitor()
    unlockCursor()
    showCursor()
    /// Don't restore position — user may have intentionally clicked elsewhere
  }

  /// When the app regains focus, re-engage if drawing mode is still active.
  private func handleAppActivation() {
    guard isActive else { return }
    /// Small delay lets the system finish its activation before we grab the cursor
    Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(50))
      self.savedCursorPosition = self.screenCursorPosition()
      self.engage()
    }
  }
}

// MARK: - Cursor Helpers
extension TrackpadMode {

  // MARK: Cursor hiding (balanced)

  private func hideCursor() {
    guard !cursorIsHidden else { return }
    NSCursor.hide()
    cursorIsHidden = true
  }

  private func showCursor() {
    guard cursorIsHidden else { return }
    NSCursor.unhide()
    cursorIsHidden = false
  }

  // MARK: Cursor locking

  private func lockCursor() {
    guard !cursorIsLocked else { return }
    CGAssociateMouseAndMouseCursorPosition(0)
    cursorIsLocked = true
  }

  private func unlockCursor() {
    guard cursorIsLocked else { return }
    CGAssociateMouseAndMouseCursorPosition(1)
    cursorIsLocked = false
  }

  // MARK: Cursor position

  private func restoreCursorPosition() {
    guard let position = savedCursorPosition else { return }

    /// `CGWarpMouseCursorPosition` uses top-left origin; convert from NSEvent's
    /// bottom-left screen coordinates.
    let screenHeight = NSScreen.main?.frame.height ?? 0
    let flipped = CGPoint(x: position.x, y: screenHeight - position.y)
    CGWarpMouseCursorPosition(flipped)
    savedCursorPosition = nil
  }

  private func screenCursorPosition() -> CGPoint {
    NSEvent.mouseLocation
  }

  // MARK: Click suppression

  private func installClickMonitor() {
    guard clickMonitor == nil else { return }
    clickMonitor = NSEvent.addLocalMonitorForEvents(
      matching: [
        .leftMouseDown, .leftMouseUp,
        .rightMouseDown, .rightMouseUp,
        .otherMouseDown, .otherMouseUp,
      ]
    ) { _ in
      /// Returning nil swallows the event
      nil
    }
  }

  private func removeClickMonitor() {
    guard let monitor = clickMonitor else { return }
    NSEvent.removeMonitor(monitor)
    clickMonitor = nil
  }
}
#endif
