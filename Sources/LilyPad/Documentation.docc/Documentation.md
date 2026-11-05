# ``Lilypad``

A Swift library to capture touch events from a Mac trackpad.

Touch data can support drawing, gesture experiments and other interactions without requiring a canvas framework.

```swift
MyInputSurface()
  .trackpadTouches(mode: .active(hidesPointer: false)) { touches, mappedRect in
    for touch in touches {
      print("Finger \(touch.touchOrder + 1): \(touch.position)")
    }
  }
  .trackpadGuideVisibility(.drawingMode)
  .trackpadTouchIndicators(true)
```

Lilypad measures the modified view by default. Pass `viewportSize:` when a parent already owns the same geometry and you want to share it without another measurement.

## Topics

### Capturing input

- <doc:TouchesModifier>
- ``TouchPoint``
- ``TouchMapping``
- ``TrackpadMappedRect``
- ``TrackpadMode``
- ``TrackpadGuideVisibility``
