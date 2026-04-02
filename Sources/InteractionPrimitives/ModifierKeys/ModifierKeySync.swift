//
//  ModifierKeySync.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 21/3/2026.
//

import SwiftUI

private struct EnvironmentSyncModifier<Value: Equatable>: ViewModifier {

  @Environment private var value: Value
  let apply: (Value) -> Void

  init(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    apply: @escaping (Value) -> Void,
  ) {
    _value = Environment(keyPath)
    self.apply = apply
  }

  func body(content: Content) -> some View {
    content.task(id: value) { apply(value) }
  }
}

//@MainActor
extension View {
  public func syncEnvironment<Value: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    apply: @escaping (Value) -> Void,
  ) -> some View {
    modifier(EnvironmentSyncModifier(keyPath, apply: apply))
  }

  public func syncEnvironment<Value: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    to binding: Binding<Value>,
  ) -> some View {
    syncEnvironment(keyPath) { binding.wrappedValue = $0 }
  }

  /// ## Custom closure
  ///
  /// ```
  /// SomeView()
  ///   .syncModifiers { newKeys in
  ///     myStore.updateKeys(newKeys)
  ///   }
  /// ```
  
  public func syncModifiers(
    apply: @escaping (Modifiers) -> Void
  ) -> some View {
    syncEnvironment(\.modifierKeys, apply: apply)
  }

  /// ## Binding
  /// ```
  /// @State private var modifiers = Modifiers()
  /// SomeView()
  ///   .syncModifiers(to: $modifiers)
  /// ```
  public func syncModifiers(to binding: Binding<Modifiers>) -> some View {
    syncModifiers { binding.wrappedValue = $0 }
  }

}
