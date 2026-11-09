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
    _ = handler.processSamples([sample(1, x: 0.75)], timestamp: 1)
    _ = handler.processSamples([sample(1, x: 0.75)], timestamp: 0)
    _ = handler.processSamples([sample(1, x: 0.75)], timestamp: .nan)
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
    _ = handler.processSamples([sample(1, x: CGFloat.infinity, phase: .ended)], timestamp: .nan)
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
  private let source = CGSize(width: 160, height: 100)

  @Test func fitFillAndStretchHaveExplicitBounds() throws {
    let destination = CGRect(x: 20, y: 30, width: 200, height: 100)
    let square = CGSize(width: 1, height: 1)
    let fit = try #require(TrackpadMapping(sourceSize: square, destination: destination))
    let fill = try #require(TrackpadMapping(sourceSize: square, destination: destination, scaling: .fill))
    let stretch = try #require(TrackpadMapping(destination: destination, scaling: .stretch))
    #expect(fit.mappedRect == CGRect(x: 70, y: 30, width: 100, height: 100))
    #expect(fill.mappedRect == CGRect(x: 20, y: -20, width: 200, height: 200))
    #expect(stretch.mappedRect == destination)
    // Fill genuinely maps beyond the target; it does not clamp or discard.
    #expect(fill.position(from: .zero) == CGPoint(x: 20, y: 180))
    #expect(fill.position(from: CGPoint(x: 1, y: 1)) == CGPoint(x: 220, y: -20))
  }

  @Test func cornersAndCentreUseTopLeftDestinationCoordinates() throws {
    let mapping = try #require(TrackpadMapping(sourceSize: source,
      destination: CGRect(x: 30, y: 40, width: 320, height: 200)))
    #expect(mapping.position(from: .zero) == CGPoint(x: 30, y: 240))
    #expect(mapping.position(from: CGPoint(x: 1, y: 0)) == CGPoint(x: 350, y: 240))
    #expect(mapping.position(from: CGPoint(x: 0, y: 1)) == CGPoint(x: 30, y: 40))
    #expect(mapping.position(from: CGPoint(x: 1, y: 1)) == CGPoint(x: 350, y: 40))
    #expect(mapping.position(from: CGPoint(x: 0.5, y: 0.5)) == CGPoint(x: 190, y: 140))
  }

  @Test(arguments: TouchMapping.allCases)
  func velocityMatchesPositionDifference(_ scaling: TouchMapping) throws {
    let mapping = try #require(TrackpadMapping(sourceSize: source,
      destination: CGRect(x: -25, y: 80, width: 300, height: 400), scaling: scaling))
    let start = CGPoint(x: 0.25, y: 0.5)
    let velocity = CGVector(dx: 0.5, dy: -0.25)
    let dt: CGFloat = 0.125
    let end = CGPoint(x: start.x + velocity.dx * dt, y: start.y + velocity.dy * dt)
    let a = mapping.position(from: start)
    let b = mapping.position(from: end)
    let mappedVelocity = mapping.velocity(from: velocity)
    #expect(abs((b.x - a.x) / dt - mappedVelocity.dx) < 1e-9)
    #expect(abs((b.y - a.y) / dt - mappedVelocity.dy) < 1e-9)
    #expect(mapping.velocity(from: .zero).dx == 0)
    #expect(mapping.velocity(from: .zero).dy == 0)
  }

  @Test func mappedTouchPreservesSourceAndTransformsVelocityAgain() throws {
    let mapping = try #require(TrackpadMapping(sourceSize: source,
      destination: CGRect(x: 10, y: 20, width: 320, height: 200)))
    let touch = TouchPoint(id: TouchID(rawValue: 7), touchOrder: 3,
      position: CGPoint(x: 0.25, y: 0.75), velocity: CGVector(dx: 0.5, dy: 0.25),
      deviceSize: source, pressure: 0.7, stage: 2, phase: .cancelled, isResting: true)
    let mapped = mapping.map(touch)
    #expect(mapped.position == CGPoint(x: 90, y: 70))
    #expect(mapped.velocity.dx == 160)
    #expect(mapped.velocity.dy == -50)
    #expect(mapped.magnitude == hypot(160, 50))
    // Rotation, nonuniform scale and translation exercise more than zoom alone.
    let transformed = mapped.transformed(by: CGAffineTransform(a: 0, b: 2, c: -3, d: 0, tx: 11, ty: 17))
    #expect(transformed.position == CGPoint(x: -199, y: 197))
    #expect(transformed.velocity.dx == 150)
    #expect(transformed.velocity.dy == 320)
    #expect(transformed.magnitude == hypot(150, 320))
    #expect(transformed.source.position == touch.position)
    #expect(transformed.source.deviceSize == source)
    #expect(transformed.id == touch.id)
    #expect(transformed.touchOrder == 3)
    #expect(transformed.phase == .cancelled)
    #expect(transformed.pressure == 0.7)
    #expect(transformed.stage == 2)
    #expect(transformed.isResting)
  }

  @Test(arguments: [CGFloat.zero, -1, .infinity, -.infinity, .nan])
  func invalidGeometryIsRejected(_ value: CGFloat) {
    for scaling in TouchMapping.allCases {
      #expect(TrackpadMapping(sourceSize: source,
        destination: CGRect(x: 0, y: 0, width: value, height: 100), scaling: scaling) == nil)
      #expect(TrackpadMapping(sourceSize: source,
        destination: CGRect(x: 0, y: 0, width: 100, height: value), scaling: scaling) == nil)
    }
    for scaling in [TouchMapping.fit, .fill] {
      #expect(TrackpadMapping(sourceSize: CGSize(width: value, height: 100),
        destination: CGRect(x: 0, y: 0, width: 100, height: 100), scaling: scaling) == nil)
    }
  }

  @Test func unknownSourceAndOverflowHaveNoInventedFallback() {
    let destination = CGRect(x: 0, y: 0, width: 200, height: 100)
    #expect(TrackpadMapping(destination: destination) == nil)
    #expect(TrackpadMapping(destination: destination, scaling: .fill) == nil)
    #expect(TrackpadMapping(destination: destination, scaling: .stretch) != nil)
    #expect(TrackpadMapping(sourceSize: CGSize(width: 1, height: 2),
      destination: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 100), scaling: .fill) == nil)
    #expect(TrackpadMapping(destination: CGRect(x: CGFloat.infinity, y: 0, width: 10, height: 10), scaling: .stretch) == nil)
    #expect(TrackpadMapping(destination: CGRect(x: CGFloat.greatestFiniteMagnitude, y: 0, width: 1, height: 10), scaling: .stretch) == nil)
  }

  @Test func physicalProportionsMatterButAbsoluteDeviceSizeDoesNot() throws {
    let target = CGRect(x: 0, y: 0, width: 400, height: 400)
    let a = try #require(TrackpadMapping(sourceSize: source, destination: target))
    let b = try #require(TrackpadMapping(sourceSize: CGSize(width: 320, height: 200), destination: target))
    #expect(a == b)
    // Equal physical travel along each device axis should map to equal lengths.
    let x = a.velocity(from: CGVector(dx: 10 / source.width, dy: 0))
    let y = a.velocity(from: CGVector(dx: 0, dy: 10 / source.height))
    #expect(abs(x.dx + y.dy) < 1e-9)
  }
}

struct NormalisedCaptureTests {
  @Test func malformedSamplesNeverEscapeUnitSquare() {
    let handler = TrackpadTouchHandler()
    #expect(handler.processSamples([sample(1, x: -0.01)], timestamp: 0).isEmpty)
    let first = handler.processSamples([sample(1, x: 0.5)], timestamp: 1)[0]
    let invalid = handler.processSamples([sample(1, x: 1.01)], timestamp: 2)[0]
    #expect(invalid.position == first.position)
    let ended = handler.processSamples([sample(1, x: .nan, phase: .ended)], timestamp: 3)[0]
    #expect(ended.id == first.id)
    #expect(ended.position == first.position)
    #expect(ended.phase == .ended)
    #expect(handler.processSamples([sample(2)], timestamp: 4)[0].touchOrder == 0)
  }

  @Test func deviceGeometryIsPerContactAndSurvivesMissingTerminalMetadata() {
    let handler = TrackpadTouchHandler()
    var first = sample(1, x: 0.25)
    first.deviceSize = CGSize(width: 160, height: 100)
    var second = sample(2, x: 0.75)
    second.deviceSize = CGSize(width: 120, height: 120)
    let initial = handler.processSamples([first, second], timestamp: 1)
    #expect(initial[0].deviceSize == first.deviceSize)
    #expect(initial[1].deviceSize == second.deviceSize)
    let terminal = handler.processSamples([sample(1, phase: .ended)], timestamp: 2)[0]
    #expect(terminal.deviceSize == first.deviceSize)
    var invalid = sample(3)
    invalid.deviceSize = CGSize(width: CGFloat.nan, height: 100)
    #expect(handler.processSamples([invalid], timestamp: 3)[0].deviceSize == nil)
  }

  @Test func upwardMovementHasPositiveNormalisedVelocity() {
    let handler = TrackpadTouchHandler()
    handler.smoothingFactor = 1
    let identity = ContactIdentity(1)
    _ = handler.processSamples([TrackpadTouchSample(identity: identity,
      position: CGPoint(x: 0.25, y: 0.25), phase: .began)], timestamp: 1)
    let next = handler.processSamples([TrackpadTouchSample(identity: identity,
      position: CGPoint(x: 0.75, y: 0.5), phase: .moved)], timestamp: 1.5)[0]
    #expect(next.velocity.dx == 1)
    #expect(next.velocity.dy == 0.5)
    #expect(next.magnitude == hypot(1, 0.5))
  }
}
