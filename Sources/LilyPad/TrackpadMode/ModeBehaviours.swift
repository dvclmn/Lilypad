//
//  ModeBehaviours.swift
//  InteractionKit
//
//  Created by Dave Coleman on 1/4/2026.
//

extension TrackpadMode {
  
  /// Pointer behaviours that can be independently toggled.
  public struct Behaviours: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    /// Hide the cursor while drawing.
    public static let hide = Behaviours(rawValue: 1 << 0)
    
    /// Lock cursor position so it can't move to other windows/screens.
    public static let lock = Behaviours(rawValue: 1 << 1)
    
    /// Suppress mouse clicks to prevent accidental focus changes.
    public static let suppressClicks = Behaviours(rawValue: 1 << 2)
    
    /// All behaviours enabled.
    public static let all: Behaviours = [.hide, .lock, .suppressClicks]
  }
}
