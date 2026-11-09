# Capturing trackpad touches

Read normalised input without selecting a mapping target.

```swift
Color.clear
  .trackpadTouches(isEnabled: capturesTouches) { touches in
    handleNormalisedTouches(touches)
  }
```

The modifier overlays an AppKit capture view. It has no geometry reader, viewport-size argument, mapping policy or implicit guide. It therefore has no destination-size validity check. AppKit still needs an attached, suitably laid-out receiving view and normal event routing; independence from mapping geometry does not guarantee that a zero-sized view receives hardware events.

The callback delivers ordered updates including ended and cancelled contacts. Each update can contain only a subset of active contacts. Preserve active state by `TouchID`, not by replacing the entire active set on every event. Capture identity is scoped to its session.

`isEnabled: false` removes the capture view. Removal cannot deliver remaining terminal events, so clear application-owned active state when disabling or removing capture. Normal cancellation events remain part of the callback contract.

See <doc:NormalisedCoordinates> for origins, units, input validation and source geometry, and <doc:MappingTouches> for conversion and presentation.
