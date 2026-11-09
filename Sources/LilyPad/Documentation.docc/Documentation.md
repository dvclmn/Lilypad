# ``Lilypad``

Capture normalised trackpad input on macOS, then explicitly map it into a coordinate space chosen by your application.

```swift
MyInputSurface()
  .trackpadTouches(isEnabled: true) { touches in
    for touch in touches {
      print(touch.position, touch.velocity, touch.deviceSize as Any)
    }
  }
```

Capture never measures a destination or changes its output units. Mapping and presentation are separate, optional facilities. Lilypad has no drawing mode, artwork model or canvas dependency.

## Topics

### Capturing input

- <doc:TouchesModifier>
- <doc:NormalisedCoordinates>
- ``TouchPoint``
- ``TouchID``
- <doc:TrackpadMode>

### Mapping and presentation

- <doc:MappingTouches>
- ``TrackpadMapping``
- ``TouchMapping``
- ``MappedTouchPoint``
- ``TrackpadGuideView``
- ``TouchIndicatorsView``

### Migration

- <doc:MappingMigration>
