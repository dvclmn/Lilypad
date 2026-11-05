# Trackpad mode and pointer behaviour

Control touch capture and pointer hiding with ``TrackpadMode``.

`.inactive` disables capture. `.active(hidesPointer: false)` enables capture with standard pointer behaviour. `.active(hidesPointer: true)` also engages pointer hiding and locking, with restoration when the mode ends or the application loses focus.

## Usage

```swift
@State private var capturesTouches = false

var body: some View {
  MyInputSurface()
    .trackpadTouches(
      mode: capturesTouches ? .active(hidesPointer: true) : .inactive
    ) { touches, mappedRect in
      // Process input.
    }
    .trackpadGuideVisibility(.drawingMode)
    .toolbar {
      Toggle("Capture touches", isOn: $capturesTouches)
    }
}
```

The internal `TrackpadModeModifier` connects pointer management to the capture view's lifecycle. Clients pass a mode to `.trackpadTouches(...)`; no separate `.trackpadMode(...)` modifier is required.
