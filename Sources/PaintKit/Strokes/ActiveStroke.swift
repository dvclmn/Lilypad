//
//  ActiveStroke.swift
//  InteractionKit
//
//  Created by Dave Coleman on 3/4/2026.
//
import Foundation
import LilyPad

/// A stroke currently being drawn — accumulating points while a finger is down.
public struct ActiveStroke: Identifiable {

  /// Touch identity (from `NSTouch.identity`), stable for this contact's lifetime.
  public let id: TouchID

  /// Which finger this is (0-based, by arrival order).
  public let touchOrder: Int

  /// Points accumulated so far during this contact.
  public var points: [StrokePoint]
}
