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

private struct EnvironmentSyncModifierByID<Value, ID: Equatable>: ViewModifier {

  @Environment private var value: Value
  let id: (Value) -> ID
  let apply: (Value) -> Void

  init(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    id: @escaping (Value) -> ID,
    apply: @escaping (Value) -> Void,
  ) {
    _value = Environment(keyPath)
    self.id = id
    self.apply = apply
  }

  func body(content: Content) -> some View {
    content.task(id: id(value)) { apply(value) }
  }
}

extension View {

  /// ## Binding
  /// ```
  /// @State private var modifiers = Modifiers()
  /// SomeView()
  ///   .syncModifiers(to: $modifiers)
  /// ```
  public func syncEnvironment<Value: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    to binding: Binding<Value>,
  ) -> some View {
    syncEnvironment(keyPath) { binding.wrappedValue = $0 }
  }

  public func syncEnvironment<Value, ID: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    using idKeyPath: KeyPath<Value, ID>,
    to binding: Binding<Value>,
  ) -> some View {
    syncEnvironment(keyPath, using: idKeyPath) { binding.wrappedValue = $0 }
  }

  /// ## Custom closure
  ///
  /// ```
  /// SomeView()
  ///   .syncModifiers { newKeys in
  ///     myStore.updateKeys(newKeys)
  ///   }
  /// ```

  public func syncEnvironment<Value: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    apply: @escaping (Value) -> Void,
  ) -> some View {
    modifier(EnvironmentSyncModifier(keyPath, apply: apply))
  }

  public func syncEnvironment<Value, ID: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    using idKeyPath: KeyPath<Value, ID>,
    apply: @escaping (Value) -> Void,
  ) -> some View {
    modifier(
      EnvironmentSyncModifierByID(
        keyPath,
        id: { $0[keyPath: idKeyPath] },
        apply: apply,
      )
    )
  }

  //  public func syncModifiers(
  //    apply: @escaping (Modifiers) -> Void
  //  ) -> some View {
  //    syncEnvironment(\.modifierKeys, apply: apply)
  //  }

  //  public func syncModifiers(to binding: Binding<Modifiers>) -> some View {
  //    syncModifiers { binding.wrappedValue = $0 }
  //  }

}
