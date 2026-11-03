//
//  LilypadTests.swift
//  Lilypad
//
//  Created by Dave Coleman on 3/11/2026.
//

import AppKit
import Testing
@testable import Lilypad

private final class ContactIdentity: NSObject {
  let value: Int
  init(_ value: Int) { self.value = value }
  override var hash: Int { 1 }
  override func isEqual(_ object: Any?) -> Bool {
    (object as? ContactIdentity)?.value == value
  }
}

private func sample(
  _ identity: Int,
  x: CGFloat = 0,
  phase: NSTouch.Phase = .moved
) -> TrackpadTouchSample {
  TrackpadTouchSample(identity: ContactIdentity(identity), position: CGPoint(x: x, y: 0), phase: phase)
}

struct ContactTests {
  @Test func stableOrderSurvivesLiftAndNewArrival() throws {
    let handler = TrackpadTouchHandler()
    let initial = handler.processSamples([sample(1, x: 0.2), sample(2, x: 0.8)], timestamp: 1)
    #expect(initial.map(\.touchOrder) == [0, 1])
    #expect(initial[0].id != initial[1].id) // Deliberately colliding identity hashes.

    let lifted = handler.processSamples([sample(2), sample(1, phase: .ended)], timestamp: 2)
    #expect(lifted.map(\.id) == initial.map(\.id))
    #expect(lifted.map(\.touchOrder) == [0, 1])
    #expect(lifted[0].phase == .ended)

    let later = handler.processSamples([sample(3), sample(2)], timestamp: 3)
    #expect(later.map(\.touchOrder) == [1, 2])
    #expect(later[0].id == initial[1].id)
    #expect(later[1].id != initial[0].id)
  }

  @Test func simultaneousArrivalsUseSpatialOrder() {
    let handler = TrackpadTouchHandler()
    let first = handler.processSamples([sample(2, x: 0.8), sample(1, x: 0.2)], timestamp: 1)
    #expect(first.map(\.position.x) == [0.2, 0.8])
    let crossed = handler.processSamples([sample(1, x: 0.9), sample(2, x: 0.1)], timestamp: 2)
    #expect(crossed.map(\.id) == first.map(\.id))
    #expect(crossed.map(\.position.x) == [0.9, 0.1])
  }

  @Test func cancellationReleasesIdentityAndResetsOrder() {
    let handler = TrackpadTouchHandler()
    let first = handler.processSamples([sample(1)], timestamp: 1)[0]
    handler.updatePressure(0.7, stage: 2)
    let cancelled = handler.processSamples([sample(1, phase: .cancelled)], timestamp: 2)[0]
    #expect(cancelled.id == first.id)
    #expect(cancelled.pressure == 0.7)
    let next = handler.processSamples([sample(1)], timestamp: 3)[0]
    #expect(next.id != first.id)
    #expect(next.touchOrder == 0)
    #expect(next.pressure == 0)
    #expect(next.stage == 0)
  }

  @Test func emptyAndPartialEventsRetainContacts() {
    let handler = TrackpadTouchHandler()
    let initial = handler.processSamples([sample(1), sample(2, x: 1)], timestamp: 1)
    #expect(handler.processSamples([], timestamp: 2).isEmpty)
    let second = handler.processSamples([sample(2)], timestamp: 3)[0]
    #expect(second.id == initial[1].id)
    #expect(second.touchOrder == 1)
  }

  @Test func invalidTimesDoNotMoveVelocityBaseline() {
    let handler = TrackpadTouchHandler()
    handler.smoothingFactor = 1
    _ = handler.processSamples([sample(1)], timestamp: 1)
    _ = handler.processSamples([sample(1, x: 100)], timestamp: 1)
    _ = handler.processSamples([sample(1, x: 100)], timestamp: 0)
    _ = handler.processSamples([sample(1, x: 100)], timestamp: .nan)
    let next = handler.processSamples([sample(1, x: 1)], timestamp: 2)[0]
    #expect(next.velocity.dx == 1)
    #expect(next.magnitude == 1)
  }

  @Test func invalidPositionDoesNotPoisonHistoryOrPreventTermination() {
    let handler = TrackpadTouchHandler()
    handler.smoothingFactor = 1
    let first = handler.processSamples([sample(1, x: 0.5)], timestamp: 1)[0]
    let invalid = handler.processSamples([sample(1, x: .nan)], timestamp: 2)[0]
    #expect(invalid.position == first.position)
    let next = handler.processSamples([sample(1, x: 1)], timestamp: 3)[0]
    #expect(next.velocity.dx == 0.25)
    _ = handler.processSamples([sample(1, x: .infinity, phase: .ended)], timestamp: .nan)
    let restarted = handler.processSamples([sample(1)], timestamp: 4)[0]
    #expect(restarted.id != first.id)
    #expect(restarted.touchOrder == 0)
  }

  @Test func smoothingAndPressureInputsAreBounded() {
    let handler = TrackpadTouchHandler()
    handler.smoothingFactor = 2
    handler.updatePressure(2, stage: 10)
    _ = handler.processSamples([sample(1)], timestamp: 1)
    let next = handler.processSamples([sample(1, x: 1)], timestamp: 2)[0]
    #expect(next.velocity.dx == 1)
    #expect(next.pressure == 1)
    #expect(next.stage == 2)
    handler.smoothingFactor = .nan
    let smoothed = handler.processSamples([sample(1, x: 1)], timestamp: 3)[0]
    #expect(abs(smoothed.velocity.dx - 0.7) < 1e-12)
  }
}

struct MappingTests {
  @Test func customAspectRatioIsUsed() throws {
    let context = TrackpadMappingContext(guide: .always, mode: .inactive, mapping: .fit)
    let mapped = try #require(context.mappedSize(in: CGSize(width: 200, height: 100), aspectRatio: 1))
    #expect(mapped.rect == CGRect(x: 50, y: 0, width: 100, height: 100))
  }

  @Test func fitAndFillPreserveAspectRatio() throws {
    let size = CGSize(width: 200, height: 100)
    let fit = try #require(TrackpadMappedRect.makeRect(in: size, mapping: .fit, sourceAspectRatio: 1))
    let fill = try #require(TrackpadMappedRect.makeRect(in: size, mapping: .fill, sourceAspectRatio: 1))
    #expect(fit.rect == CGRect(x: 50, y: 0, width: 100, height: 100))
    #expect(fill.rect == CGRect(x: 0, y: -50, width: 200, height: 200))
  }

  @Test(arguments: [CGFloat.zero, -1, .infinity, -.infinity, .nan])
  func invalidGeometryIsRejected(_ value: CGFloat) {
    for mapping in TouchMapping.allCases {
      #expect(TrackpadMappedRect.makeRect(in: CGSize(width: value, height: 100), mapping: mapping) == nil)
      #expect(TrackpadMappedRect.makeRect(in: CGSize(width: 100, height: value), mapping: mapping) == nil)
      #expect(TrackpadMappedRect.makeRect(in: CGSize(width: 100, height: 100), mapping: mapping, sourceAspectRatio: value) == nil)
    }
  }

  @Test func overflowingMappingIsRejected() {
    #expect(TrackpadMappedRect.makeRect(
      in: CGSize(width: .greatestFiniteMagnitude, height: 100),
      mapping: .fill,
      sourceAspectRatio: 2
    ) == nil)
  }

  @Test func positionAndVelocityShareTransform() throws {
    let rect = try #require(TrackpadMappedRect.makeRect(
      in: CGSize(width: 200, height: 200), mapping: .fit, sourceAspectRatio: 0.5
    ))
    let touch = TouchPoint(
      id: TouchID(rawValue: 7), touchOrder: 3,
      position: CGPoint(x: 0.25, y: 0.75),
      velocity: CGVector(dx: 0.5, dy: 0.25), magnitude: hypot(0.5, 0.25),
      pressure: 0.7, stage: 2, phase: .ended, isResting: true
    )
    let mapped = TouchMapping.fit.mapTouches([touch], in: rect)[0]
    #expect(mapped.position == CGPoint(x: 50, y: 75))
    #expect(mapped.velocity.dx == 100)
    #expect(mapped.velocity.dy == -25)
    #expect(mapped.magnitude == hypot(100, 25))
    #expect(mapped.id == touch.id)
    #expect(mapped.touchOrder == touch.touchOrder)
    #expect(mapped.pressure == touch.pressure)
    #expect(mapped.stage == touch.stage)
    #expect(mapped.phase == touch.phase)
    #expect(mapped.isResting)

    let raw = TouchMapping.normalised.mapTouches([touch], in: rect)[0]
    #expect(raw.position == touch.position)
    #expect(raw.velocity.dx == touch.velocity.dx)
    #expect(raw.velocity.dy == touch.velocity.dy)
    #expect(raw.magnitude == touch.magnitude)
  }
}
