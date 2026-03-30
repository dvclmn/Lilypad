//
//  Pointer.swift
//  Collection
//
//  Created by Dave Coleman on 19/9/2024.
//

import SwiftUI

public enum PointerStyleCompatible: Sendable {
  /// Displays an arrow in macOS and a circle in iPadOS and visionOS.
  case `default`

  /// Appropriate for selecting or inserting text in a horizontal layout.
  /// Sometimes referred to as the I-beam pointer.
  case horizontalText

  /// Style appropriate for selecting or inserting text in a
  /// vertical layout.
  case verticalText

  /// Style for precise rectangular selection, such as selecting a portion
  /// of an image or multiple lines of text. It displays a crosshair
  case rectSelection

  /// Indicates that dragging to reposition content within specific bounds,
  /// such as panning a large image, is possible. Displays an open hand to
  /// indicate that the content can be repositioned.
  ///
  /// Typically it’s used along with `grabActive` while a mouse or trackpad is
  /// actively clicked to indicate that the content is currently being repositioned.
  case grabIdle

  /// The style for actively dragging to reposition content within specific bounds.
  /// Displays a closed hand to indicate that the content is currently being repositioned
  case grabActive

  /// The pointer style appropriate for content opens a URL link to a
  /// webpage, document, or other item when clicked. Displays a pointing hand.
  case link

  /// Indicates that the content can be zoomed in.
  /// Displays a magnifying glass with a plus symbol.
  case zoomIn
  case zoomOut

  /// The pointer style for resizing a column, or vertical division.
  case columnResize

  /// The pointer style for resizing a column, or vertical division.
  case columnResizeDirections(HorizontalDirectionCompatible.Set)

  /// Style for resizing a row, or horizontal division, in either direction.
  case rowResize

  /// Style for resizing a row, or horizontal division, in either direction.
  case rowResizeDirections(VerticalDirectionCompatible.Set)

  case frameResize(
    position: FrameResizePositionCompatible,
    directions: FrameResizeDirectionCompatible = .all,
  )
  case image(Image, hotSpot: UnitPoint)

}

extension PointerStyleCompatible {
  #if canImport(AppKit)
  @available(macOS 15, *)
  var toPointerStyle: PointerStyle {
    switch self {
      case .default: .default
      case .horizontalText: .horizontalText
      case .verticalText: .rectSelection
      case .rectSelection: .rectSelection
      case .grabIdle: .grabIdle
      case .grabActive: .grabActive
      case .link: .link
      case .zoomIn: .zoomIn
      case .zoomOut: .zoomOut

      case .columnResize: .columnResize
      case .columnResizeDirections(let dir):
        .columnResize(directions: dir.toHorizontalDirection)

      case .rowResize: .rowResize
      case .rowResizeDirections(let dir):
        .rowResize(directions: dir.toVerticalDirection)

      case .frameResize(let position, let direction):
        .frameResize(
          position: position.toResizePosition,
          directions: direction.toResizeDirection,
        )

      case .image(let image, let hotSpot): .image(image, hotSpot: hotSpot)
    }
  }
  #endif
}

extension PointerStyleCompatible {
  public var name: String {
    switch self {
      case .default: "Default"
      case .horizontalText: "Horizontal Text"
      case .verticalText: "Vertical Text"
      case .rectSelection: "Rect Selection"
      case .grabIdle: "Grab Idle"
      case .grabActive: "Grab Active"
      case .link: "Link"
      case .zoomIn: "Zoom In"
      case .zoomOut: "Zoom Out"
      case .columnResize: "Column Resize"
      case .columnResizeDirections(let set): "Column Resize Directions: \(set)"
      case .rowResize: "Row Resize"
      case .rowResizeDirections(let set): "Row Resize Directions: \(set)"
      case .frameResize(let position, let directions): "Frame Resize: \(position), \(directions)"
      case .image(let image, let hotSpot): "Image: \(image), \(hotSpot)"
    }
  }
}

extension UnitPoint {

  public var toCompatPointerStyle: PointerStyleCompatible? {
    guard let position = self.toCompatFrameResizePosition else { return nil }
    let style = PointerStyleCompatible.frameResize(
      position: position,
      directions: .all,
    )
    return style
  }

  var toCompatFrameResizePosition: FrameResizePositionCompatible? {
    switch self {
      case .topLeading: .topLeading
      case .topTrailing: .topTrailing
      case .bottomLeading: .bottomLeading
      case .bottomTrailing: .bottomTrailing
      case .top: .top
      case .trailing: .trailing
      case .leading: .leading
      case .bottom: .bottom
      default: nil
    }
  }

}
