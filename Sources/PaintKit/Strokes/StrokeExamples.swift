//
//  StrokeExamples.swift
//  Lilypad
//
//  Created by Dave Coleman on 20/4/2026.
//

import Foundation

extension Stroke {
  public static func example(in size: CGSize) -> Stroke {
    .init(
      touchOrder: 1,
      points: StrokePoint.points(in: size),
      style: .default,
    )
  }
}

extension StrokePoint {
  public static func points(in size: CGSize) -> [StrokePoint] {
    let points: [StrokePoint] = [
      .at(x: .zero, y: .zero),
      .at(x: size.width * 0.9, y: .zero),
      .at(x: size.width, y: size.height * 0.1),
      .at(x: size.width, y: size.height * 0.9),
      .at(x: size.width, y: size.height),
      .at(x: size.width * 0.9, y: size.height),
      .at(x: .zero, y: size.height),
      .at(x: .zero, y: size.height * 0.9),
      .at(x: .zero, y: .zero),
    ]
    return points
  }

}
