//
//  LayerStrokes.swift
//  Lilypad
//
//  Created by Dave Coleman on 20/4/2026.
//

public protocol DrawingLayer {
  var strokes: [Stroke] { get }
  var metadata: LayerMetadata { get }
  func filteredStrokes(using: StrokeFilterType) -> [Stroke]
  
}
