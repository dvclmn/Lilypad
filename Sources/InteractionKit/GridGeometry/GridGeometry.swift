//
//  GridGeometry.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 27/2/2026.
//

//import CoreGraphics
//import SwiftUI


/// Continuous/discrete geometry for grid documents.
//public struct GridGeometry: Sendable, Equatable {
//  public let viewportRect: Rect<ScreenSpace>
//  public let dimensions: GridDimensions
//  public let projection: GridProjection
//
//  /// What is the canvas/artwork's anchor in the parent view
//  public var anchor: UnitPoint
//
//  public init(
//    viewportRect: Rect<ScreenSpace> = .zero,
//    dimensions: GridDimensions,
//    projection: GridProjection,
//    anchor: UnitPoint = .center
//  ) {
//    self.viewportRect = viewportRect
//    self.dimensions = dimensions
//    self.projection = projection
//    self.anchor = anchor
//  }
//}
//
//extension GridGeometry {
//
//  public init(
//    viewportRect: Rect<ScreenSpace> = .zero,
//    dimensions: GridDimensions,
//    unitSize: CGSize,
//    rounding: GridRounding = .down,
//    anchor: UnitPoint = .center
//  ) {
//    self.viewportRect = viewportRect
//    self.dimensions = dimensions
//    self.projection = GridProjection(
//      unitSize: unitSize,
//      rounding: rounding
//    )
//    self.anchor = anchor
//  }
//  //}
//
//  //extension GridGeometry: CanvasViewportContext {
//  public var canvasSize: Size<CanvasSpace> {
//    projection.canvasSize(for: dimensions)
//  }
//}
//
//extension GridGeometry: CustomStringConvertible {
//  public var description: String {
//    DisplayString {
//      Labeled("Viewport", value: viewportRect)
//      Labeled("Grid Dimensions", value: dimensions.description + " Cells")
//      Labeled("Projection", value: projection)
//    }.text
//  }
//}

//extension CanvasGeometry {
//  public init?(
//    viewportRect: Rect<ScreenSpace>,
//    gridDimensions: GridDimensions,
//    unitSize: CGSize,
//    anchor: UnitPoint
//  ) {
////    guard
//      let size = gridDimensions.toScreenSize(using: unitSize)
////    else { return nil }
//    self.init(
//      viewportRect: viewportRect,
//      canvasSize: Size<CanvasSpace>(fromCGSize: size),
//      anchor: anchor
//    )
//  }
//}
