//
//  ConversionSafetyPolicy.swift
//  BaseHelpers
//
//  Created by Dave Coleman on 22/3/2026.
//

public enum ConversionSafetyPolicy {
  
  /// Returns Bool or nil paths (for current optional APIs)
  case checkOnly

  /// Debug-only assertions
  case assertDebug

  /// Precondition in all builds
  case enforceRuntime

}
