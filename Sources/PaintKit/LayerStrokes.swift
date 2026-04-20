//
//  LayerStrokes.swift
//  Lilypad
//
//  Created by Dave Coleman on 20/4/2026.
//

public protocol StrokesProvider {
  var strokes: [Stroke] { get }
  func filteredStrokes(using: StrokeFilterType) -> [Stroke]
}
