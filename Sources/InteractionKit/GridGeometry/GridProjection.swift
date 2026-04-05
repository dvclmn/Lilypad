//
//  GridProjection.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 28/2/2026.
//

import Foundation


/// Bridges the gap between pure Grid dimensions and Canvas (continuous) space.
/// Note: The only piece that needs to know about e.g.  ASCII cell size.
public struct GridProjection: Equatable, Sendable {

  /// The size of a single grid cell in Canvas Space.
  /// Aka `cellSize`
  public let unitSize: CGSize
  public var rounding: GridRounding = .down

  public init(
    unitSize: CGSize,
    rounding: GridRounding = .down
  ) {
    self.unitSize = unitSize
    self.rounding = rounding
  }
}

extension GridProjection {

  /// Converts Canvas space (continuous) to Grid space (discrete).
  /// Returns `nil` when input cannot be safely converted.
  public func gridPositionIfValid(
    from point: Point<CanvasSpace>
  ) -> GridPosition? {

    guard
      let column = point.x.toGridCount(using: unitSize.width, rounding: rounding),
      let row = point.y.toGridCount(using: unitSize.height, rounding: rounding)
    else {
      printMissing("column / row", for: "gridPositionIfValid(from:)")
      return nil
    }

    return GridPosition(column: column, row: row)
  }

  /// Converts Canvas space (continuous) to Grid space (discrete).
  /// Falls back to `.zero` when input is invalid.
  public func gridPosition(from point: Point<CanvasSpace>) -> GridPosition {
    gridPositionIfValid(from: point) ?? .zero
  }

  // MARK: - Grid to Canvas

  public func canvasPoint(for position: GridPosition) -> Point<CanvasSpace> {
    let point = GridScreenConversion.screenPoint(for: position, unitSize: unitSize)
    return Point<CanvasSpace>(fromPoint: point)
  }

  public func canvasSize(for dimensions: GridDimensions) -> Size<CanvasSpace> {
    let size = dimensions.toScreenSize(using: unitSize)
    return .init(fromCGSize: size)
  }

  public func canvasCGSize(for dimensions: GridDimensions) -> CGSize {
    let size = canvasSize(for: dimensions)
    return CGSize(fromSize: size)
  }

  // MARK: - Canvas to Grid
  public func gridDimensions(
    for canvasSize: Size<CanvasSpace>,
    rounding: GridRounding? = nil
  ) -> GridDimensions? {
    let strategy = rounding ?? self.rounding
    return CGSize(
      width: canvasSize.width,
      height: canvasSize.height
    )
    .toGridDimensions(using: unitSize, rounding: strategy)
  }

  public func gridDimensions(
    for canvasSize: CGSize,
    rounding: GridRounding? = nil
  ) -> GridDimensions? {
    let strategy = rounding ?? self.rounding
    return canvasSize.toGridDimensions(using: unitSize, rounding: strategy)
  }
}

extension GridProjection: CustomStringConvertible {
  public var description: String {
    DisplayString {
      Labeled("Unit Size", value: unitSize.displayString(.concise))
      Labeled("Rounding", value: rounding.name)
    }.text
  }
}
