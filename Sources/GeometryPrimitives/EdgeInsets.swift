//
//  EdgeInsets.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 3/8/2025.
//

import SwiftUI

extension EdgeInsets {

  public static func make(
    top: CGFloat = 0,
    leading: CGFloat = 0,
    bottom: CGFloat = 0,
    trailing: CGFloat = 0
  ) -> Self {
    self.init(
      top: top,
      leading: leading,
      bottom: bottom,
      trailing: trailing
    )
  }
  /// This permits the omission of any one of the four
  /// parameters, which the default init doesn't allow for.
  //  public init(
  //    topWithDefaults top: CGFloat = 0,
  //    leading: CGFloat = 0,
  //    bottom: CGFloat = 0,
  //    trailing: CGFloat = 0
  //  ) {
  //    self.init(
  //      top: top,
  //      leading: leading,
  //      bottom: bottom,
  //      trailing: trailing
  //    )
  //  }

  public static var zero: EdgeInsets { EdgeInsets() }

  /// A "Synthetic" property for uniform horizontal padding
  var horizontalUniform: CGFloat {
    get { (leading + trailing) / 2 }
    set {
      leading = newValue
      trailing = newValue
    }
  }

  var verticalUniform: CGFloat {
    get { (top + bottom) / 2 }
    set {
      top = newValue
      bottom = newValue
    }
  }
}
