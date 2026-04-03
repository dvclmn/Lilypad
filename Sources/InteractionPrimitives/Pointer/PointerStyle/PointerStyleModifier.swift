//
//  PointerStyleModifier.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 15/6/2025.
//

import SwiftUI

private struct CustomPointerModifier: ViewModifier {
  let style: PointerStyleCompatible?

  func body(content: Content) -> some View {
    if #available(macOS 15, *) {
      content.pointerStyle(style?.toPointerStyle)
    } else {
      content
    }
  }
}

extension View {
  public func pointerStyleCompatible(_ style: PointerStyleCompatible?) -> some View {
    modifier(CustomPointerModifier(style: style))
  }
}
