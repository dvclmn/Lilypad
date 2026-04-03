//
//  ContentView.swift
//  LilyPadDemo
//

import SwiftUI

/// LilyPad (`.trackpadTouches`) captures raw multi-touch input and
/// delivers ordered `[TouchPoint]` with stable finger numbering.
///
/// `StrokeEngine` accumulates those touches into active and completed
/// strokes, handling the began/changed/ended lifecycle.
///
/// `DrawingCanvas` renders the strokes using SwiftUI Canvas.
///
/// Additionally, `TrackpadMode` manages the pointer behaviour.
/// This involves hiding/locking the cursor while drawing so it doesn't interfere
/// with the trackpad-based absolute positioning experience.
public struct PaintDemoView: View {
  @State private var engine = StrokeEngine()
  @State private var drawingMode = TrackpadMode()
  @State private var showIndicators = true

  public init() {}

  public var body: some View {

    DrawingCanvas(engine: engine)
      .trackpadTouches(
        isEnabled: drawingMode.isActive,
        showIndicators: showIndicators,
      ) { touches in
        engine.processTouches(touches)
      }
      .trackpadMode(drawingMode)

      .overlay(alignment: .bottomLeading) {
        StatsOverlay()
      }
      .overlay(alignment: .center) {
        if !drawingMode.isActive {
          ModePromptOverlay()
        }
      }
      .toolbar {
        ToolbarItemGroup {
          Toggle("Drawing Mode", isOn: $drawingMode.isActive)
            .keyboardShortcut("d")

          Divider()

          Toggle("Indicators", isOn: $showIndicators)
            .disabled(!drawingMode.isActive)

          Button("Undo") { engine.undo() }
            .keyboardShortcut("z")
            .disabled(engine.completedStrokes.isEmpty)

          Button("Clear") { engine.clear() }
            .disabled(engine.completedStrokes.isEmpty)
        }
      }
  }
}

extension PaintDemoView {

  @ViewBuilder
  private func ModePromptOverlay() -> some View {
    VStack(spacing: 8) {
      Text("Drawing Mode is off")
        .font(.title3)
      Text("Toggle it on with the toolbar button or \(Text("⌘D").bold())")
        .font(.callout)
        .foregroundStyle(.secondary)
    }
    .padding()
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

  }

  @ViewBuilder
  private func StatsOverlay() -> some View {
    VStack(alignment: .leading, spacing: 4) {
      if drawingMode.isActive {
        Text("Drawing mode: ON")
          .foregroundStyle(.green)
      }
      Text("\(engine.completedStrokes.count) strokes")
      Text("\(engine.totalPointCount) points")
      if engine.isDrawing {
        Text("\(engine.activeStrokes.count) active")
          .foregroundStyle(.green)
      }
    }
    .monospacedDigit()
    .font(.caption)
    .foregroundStyle(.secondary)
    .padding(8)

  }
}
