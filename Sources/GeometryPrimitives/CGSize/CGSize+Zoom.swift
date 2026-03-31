//
//  CGSize+Zoom.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 7/3/2026.
//

import Foundation

extension CGSize {
  public func addingZoom(_ zoom: CGFloat) -> CGSize {
    return self * zoom
  }

  public func removingZoom(_ zoom: CGFloat) -> CGSize {
    return self / zoom
  }

  func removingZoomPercent(_ zoomPercent: CGFloat) -> CGSize {
    let adjustedWidth = self.width.removingZoomPercent(zoomPercent)
    let adjustedHeight = self.height.removingZoomPercent(zoomPercent)
    return CGSize(width: adjustedWidth, height: adjustedHeight)
  }
}
