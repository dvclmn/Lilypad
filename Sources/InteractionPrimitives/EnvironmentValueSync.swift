//
//  ModifierKeySync.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 21/3/2026.
//

import SwiftUI

private struct EnvironmentSyncModifier<Value, ID: Equatable>: ViewModifier {

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
    _ keyPath: KeyPath<EnvironmentValues, Value?>,
    to binding: Binding<Value?>,
  ) -> some View {
    syncEnvironment(keyPath) { binding.wrappedValue = $0 }
  }

  public func syncEnvironment<Value, ID: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value?>,
    using idKeyPath: KeyPath<Value?, ID>,
    to binding: Binding<Value?>,
  ) -> some View {
    syncEnvironment(keyPath, id: { $0[keyPath: idKeyPath] }, to: binding)
  }

  public func syncEnvironment<Value, ID: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value?>,
    id: @escaping (Value?) -> ID,
    to binding: Binding<Value?>,
  ) -> some View {
    syncEnvironment(keyPath, id: id) { binding.wrappedValue = $0 }
  }

  /// ## Custom closure
  ///
  /// ```
  /// SomeView()
  ///   .syncModifiers { newKeys in
  ///     myStore.updateKeys(newKeys)
  ///   }
  /// ```
  //  public func syncEnvironment<Value: Equatable>(
  //    _ keyPath: KeyPath<EnvironmentValues, Value?>,
  //    apply: @escaping (Value?) -> Void,
  //  ) -> some View {
  //    modifier(EnvironmentSyncModifier(keyPath, id: { $0 }, apply: apply))
  //  }
  //
  public func syncEnvironment<Value: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value>,
    apply: @escaping (Value) -> Void,
  ) -> some View {
    modifier(EnvironmentSyncModifier(keyPath, id: { $0 }, apply: apply))
  }

  public func syncEnvironment<Value, ID: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value?>,
    using idKeyPath: KeyPath<Value?, ID>,
    apply: @escaping (Value?) -> Void,
  ) -> some View {
    syncEnvironment(keyPath, id: { $0[keyPath: idKeyPath] }, apply: apply)
  }

  public func syncEnvironment<Value, ID: Equatable>(
    _ keyPath: KeyPath<EnvironmentValues, Value?>,
    id: @escaping (Value?) -> ID,
    apply: @escaping (Value?) -> Void,
  ) -> some View {
    modifier(EnvironmentSyncModifier(keyPath, id: id, apply: apply))
  }

}
