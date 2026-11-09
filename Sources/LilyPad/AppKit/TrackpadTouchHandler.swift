//
//  TrackpadTouchHandler.swift
//  Lilypad
//
//  Created by Dave Coleman on 3/5/2025.
//

import AppKit

/// Processes trackpad events with stable identities, contact order and EMA velocity.
/// State belongs to this capture session, so the handler has reference semantics.
final class TrackpadTouchHandler {
  var smoothingFactor: CGFloat = 0.3

  private struct Contact {
    let identity: any NSObjectProtocol
    let id: TouchID
    let order: Int
    var state: TouchState?
    var lastPosition: CGPoint
    var deviceSize: CGSize?
  }

  // Equality, rather than hash values, distinguishes AppKit identities. The small
  // number of simultaneous fingers makes a linear lookup sufficient.
  private var contacts: [Contact] = []
  private var nextID = 0
  private var nextOrder = 0

  private(set) var currentPressure: CGFloat = 0
  private(set) var currentStage: Int = 0

  func updatePressure(_ pressure: CGFloat, stage: Int) {
    currentPressure = pressure.isFinite ? min(max(pressure, 0), 1) : 0
    currentStage = min(max(stage, 0), 2)
  }

  func processTouches(
    _ nsTouches: Set<NSTouch>,
    timestamp: TimeInterval,
  ) -> [TouchPoint] {
    processSamples(
      nsTouches.filter { $0.type == .indirect }.map {
        TrackpadTouchSample(
          identity: $0.identity,
          position: $0.normalizedPosition,
          phase: $0.phase,
          isResting: $0.isResting,
          deviceSize: $0.deviceSize,
        )
      }, timestamp: timestamp,)
  }

  /// Simultaneous arrivals are ordered left-to-right, then bottom-to-top.
  /// Coincident arrivals have no physical ordering; their issued order is retained.
  /// Missing contacts are retained: an empty/partial event is not a terminal event.
  func processSamples(
    _ samples: [TrackpadTouchSample],
    timestamp: TimeInterval,
  ) -> [TouchPoint] {
    var results: [TouchPoint] = []
    var finished: Set<TouchID> = []
    let ordered = samples.sorted {
      let lhsX = $0.position.x.isFinite ? $0.position.x : 0
      let rhsX = $1.position.x.isFinite ? $1.position.x : 0
      if lhsX != rhsX { return lhsX < rhsX }
      let lhsY = $0.position.y.isFinite ? $0.position.y : 0
      let rhsY = $1.position.y.isFinite ? $1.position.y : 0
      return lhsY < rhsY
    }

    for sample in ordered {
      let isValidPosition =
        sample.position.x.isFinite && sample.position.y.isFinite
        && (0...1).contains(sample.position.x) && (0...1).contains(sample.position.y)
      let index: Int
      if let existing = contacts.firstIndex(where: { $0.identity.isEqual(sample.identity) }) {
        index = existing
      } else {
        // Do not invent a corner touch from a malformed first sample.
        guard isValidPosition else { continue }
        index = contacts.count
        contacts.append(
          Contact(
            identity: sample.identity,
            id: TouchID(rawValue: nextID),
            order: nextOrder,
            lastPosition: sample.position,
            deviceSize: validatedTouchDeviceSize(sample.deviceSize),
          ))
        nextID += 1
        nextOrder += 1
      }

      var contact = contacts[index]
      let isTerminal = sample.phase == .ended || sample.phase == .cancelled
      if isTerminal { finished.insert(contact.id) }

      // Invalid samples must not poison the next velocity calculation. A terminal
      // sample still releases the contact, using its last valid position if needed.
      let position = isValidPosition ? sample.position : contact.lastPosition
      if isValidPosition { contact.lastPosition = position }
      if let size = validatedTouchDeviceSize(sample.deviceSize) {
        contact.deviceSize = size
      }
      var velocity = contact.state?.smoothedVelocity ?? .zero
      if timestamp.isFinite && isValidPosition {
        if let previous = contact.state {
          let dt = CGFloat(timestamp - previous.lastTimestamp)
          if dt.isFinite && dt > 0 {
            velocity = .smoothed(
              previous: previous.smoothedVelocity,
              prevPosition: previous.lastPosition,
              currentPosition: position,
              factor: smoothingFactor,
              dt: dt,
            )
            contact.state = TouchState(
              lastPosition: position, lastTimestamp: timestamp, smoothedVelocity: velocity,)
          }
          // Repeated/backwards timestamps leave the valid baseline untouched.
        } else {
          contact.state = TouchState(lastPosition: position, lastTimestamp: timestamp)
        }
      }
      contacts[index] = contact
      results.append(
        TouchPoint(
          id: contact.id,
          touchOrder: contact.order,
          position: position,
          velocity: velocity,
          deviceSize: contact.deviceSize,
          pressure: currentPressure,
          stage: currentStage,
          phase: sample.phase,
          isResting: sample.isResting,
        ))
    }

    contacts.removeAll { finished.contains($0.id) }
    if contacts.isEmpty {
      nextOrder = 0
      currentPressure = 0
      currentStage = 0
    }
    return results.sorted { $0.touchOrder < $1.touchOrder }
  }
}
