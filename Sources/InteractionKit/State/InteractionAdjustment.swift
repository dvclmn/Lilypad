//
//  Interaction.swift
//  InteractionKit
//
//  Created by Dave Coleman on 8/4/2026.
//

/// Was first `CanvasAdjustment`, then `Interaction`,
/// now `InteractionAdjustment`
public enum InteractionAdjustment: Sendable {
  case transform(TransformAdjustment)
  case pointer(PointerAdjustment)
}


//public enum Interaction {
//  case gesture // multi touch
//  case pointer // single touch
//}
//
