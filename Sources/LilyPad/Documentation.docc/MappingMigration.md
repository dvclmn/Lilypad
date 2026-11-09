# Migrating to normalised capture

This migration deliberately changes public APIs while Lilypad's consumers are locally controlled.

| Previous API | Replacement |
| --- | --- |
| `trackpadTouches(mapping:perform:)` and its two-argument callback | `trackpadTouches(isEnabled:perform:)` with normalised `[TouchPoint]` |
| `viewportSize:` capture overload | Measure the consumer's target and resolve `TrackpadMapping` separately |
| `TouchMapping.normalised` | Normalised input is now unconditional; no policy case is needed |
| `TouchMapping.fit` / `.fill` | Retained raw values for explicit geometry, plus `.stretch` |
| `TrackpadMappedRect` and its unchecked initializer | Validated `TrackpadMapping(sourceSize:destination:scaling:)` and `mappedRect` |
| Mapped coordinates stored in `TouchPoint` | `MappedTouchPoint`, retaining the normalised `source` |
| Mutable `TouchPoint.position` / `withPosition` | Immutable source sample; map or transform position and velocity together |
| Caller-supplied `magnitude` | Computed from velocity, so it cannot become stale |
| Implicit capture guide/indicators | Explicit `TrackpadGuideView(mapping:)` / `TouchIndicatorsView(touches:)` |
| Assumed `CGSize.trackpadAspectRatio` / `trackpadSize` | Deprecated; use `TouchPoint.deviceSize` or an explicit consumer fallback |

A `TouchPoint` initializer now requires a finite position within `0...1` on each axis and finite velocity. Use `deviceSize:` for optional validated source dimensions. A mapped position must never be passed to this initializer.

Deprecated forwarding capture overloads are deliberately omitted: they would preserve the ambiguous output contract. The two old fixed-size convenience properties have deprecation messages because those replacements can be explained without preserving an unsafe capture path.

Paperbark keeps viewport targeting for this pass. Its input, indicators and guides use the same mapping resolver; its stroke engine accepts canvas-space `MappedTouchPoint` values. Its existing fit/fill preferences retain their raw values, and any legacy `normalised` preference migrates to fit. Before source geometry is available, Paperbark explicitly chooses a 16:10 approximation; it replaces that with reported geometry when available. No hardware assumption remains in Lilypad's mapping helper.

## Verification on hardware

Check all four trackpad corners and the centre, then verify equal physical horizontal/vertical movements under fit/fill. Compare stroke positions with indicators after pan, zoom, resize and scaling-policy changes. Check separate finger lifts, resting contacts, cancellation, capture toggling and reconnecting or switching trackpads. Fit can leave target regions unreachable; fill can put touches outside the target; neither is itself a coordinate bug. Automated geometry tests cannot establish AppKit routing or physical calibration on a real device.

## Running the regression suite

The shared `Lilypad` workspace scheme includes the Swift Testing target:

```sh
xcodebuild test -workspace Lilypad.xcworkspace -scheme Lilypad -destination 'platform=macOS'
```

Tests cover contact identity and partial updates, malformed samples and timestamps, source geometry retention, four-corner placement, fit/fill/stretch, velocity transformations, metadata preservation and invalid mapping geometry.
