//
//  StrokeData.swift
//  InteractionKit
//
//  Created by Dave Coleman on 5/4/2026.
//

protocol StrokeData {
  var touchOrder: Int { get }
  var points: [StrokePoint] { get }
}
