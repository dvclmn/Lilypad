//
//  File.swift
//
//
//  Created by Dave Coleman on 23/7/2024.
//

//import EnumMacros
import SwiftUI

public struct Modifiers: OptionSet, Sendable, Hashable {
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  public let rawValue: Int

  public static let shift = Self(rawValue: 1 << 0)
  public static let option = Self(rawValue: 1 << 1)
  public static let command = Self(rawValue: 1 << 2)
  public static let control = Self(rawValue: 1 << 3)
  public static let capsLock = Self(rawValue: 1 << 4)
  public static let numericPad = Self(rawValue: 1 << 5)

  public static let all: Self = [
    .shift,
    .option,
    .command,
    .control,
    .capsLock,
    .numericPad,
  ]

  //  public static let all: Self = [
  //    .swipe,
  //    .pinch,
  //    .pointerHover,
  //    .pointerTap,
  //    .pointerDrag
  //  ]
}

/// A representation of Modifier keys that doesn't use SwiftUI or AppKit
//@SetOfOptions<Int>
//public struct Modifiers: Sendable, Hashable {
//  public enum Options: Int, CaseIterable, Identifiable, Hashable, Equatable {
//    case shift
//    case option
//    case command
//    case control
//    case capsLock
//    case numericPad
//  }
//}

//extension Modifiers.Options {
//  public var id: Int { rawValue }
//}

extension Modifiers {
  #if canImport(AppKit)
  public init(from event: NSEvent) {
    let flags = event.modifierFlags
    var result: Modifiers = []
    if flags.contains(.shift) { result.insert(.shift) }
    if flags.contains(.control) { result.insert(.control) }
    if flags.contains(.option) { result.insert(.option) }
    if flags.contains(.command) { result.insert(.command) }
    if flags.contains(.capsLock) { result.insert(.capsLock) }
    if flags.contains(.numericPad) { result.insert(.numericPad) }
    self = result
  }
  #endif

  public init(from swiftUIKey: EventModifiers) {
    var result: Modifiers = []
    if swiftUIKey.contains(.shift) { result.insert(.shift) }
    if swiftUIKey.contains(.control) { result.insert(.control) }
    if swiftUIKey.contains(.option) { result.insert(.option) }
    if swiftUIKey.contains(.command) { result.insert(.command) }
    if swiftUIKey.contains(.capsLock) { result.insert(.capsLock) }
    if swiftUIKey.contains(.numericPad) { result.insert(.numericPad) }
    self = result
  }

  public var isHoldingCapsLock: Bool { contains(.capsLock) }
  public var isHoldingShift: Bool { contains(.shift) }
  public var isHoldingControl: Bool { contains(.control) }
  public var isHoldingOption: Bool { contains(.option) }
  public var isHoldingCommand: Bool { contains(.command) }

  public var isCapsLockOnly: Bool { self == [.capsLock] }
  public var isShiftOnly: Bool { self == [.shift] }
  public var isControlOnly: Bool { self == [.control] }
  public var isOptionOnly: Bool { self == [.option] }
  public var isCommandOnly: Bool { self == [.command] }
}

extension Modifiers {

  struct Metadata: Hashable {
    let name: String
    let symbol: String
  }

  private static let metadata: [Modifiers: Modifiers.Metadata] = [
    .shift: .init(name: "Shift", symbol: "􀆝"),
    .control: .init(name: "Control", symbol: "􀆍"),
    .option: .init(name: "Option", symbol: "􀆕"),
    .command: .init(name: "Command", symbol: "􀆔"),
    .capsLock: .init(name: "Caps Lock", symbol: "􀆡"),
    .numericPad: .init(name: "Numeric Pad", symbol: "􀅱"),
  ]

  //  private var individualOptions: [Modifiers] {
  //    Modifiers.metadata.keys.filter { contains($0) }
  //  }

}

public struct ModifierDisplayElements: OptionSet, Sendable {
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  public let rawValue: Int

  public static let name = Self(rawValue: 1 << 0)
  public static let icon = Self(rawValue: 1 << 1)
  public static let both: Self = [.name, .icon]
}
