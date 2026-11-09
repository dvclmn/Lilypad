# Mapping touches explicitly

Resolve one mapping and use its results for input, guides and indicators.

## Resolve geometry

```swift
let mapping = TrackpadMapping(
  sourceSize: touch.deviceSize,
  destination: CGRect(x: 20, y: 30, width: 600, height: 400),
  scaling: .fit
)
if let mapping {
  let mapped = mapping.map(touch)
  // mapped.position: destination units, top-left origin
  // mapped.velocity: destination units per second, Y downwards
}
```

The helper is a value type because it describes a resolved transform, without an event lifecycle or mutable session. The destination rectangle can represent any consumer-selected region. Its offset matters. Lilypad does not know whether it represents an artwork, viewport, control or something else.

| Policy | Behaviour |
| --- | --- |
| `fit` | Centre the whole source inside the target, preserving proportions. Some target regions may be unreachable. |
| `fill` | Centre and enlarge the source to cover the target, preserving proportions. Some mapped touches can land beyond the target. |
| `stretch` | Map the four source corners to the four target corners, potentially distorting physical shapes. |

Fit/fill require finite, positive source dimensions. Stretch works without them. Empty, invalid, overflowing or numerically collapsed destination geometry fails with `nil`. Failure to resolve a mapping does not suspend normalised capture. Applications must finish or cancel their own interaction if they cannot continue mapping it.

Fill is a geometric cover operation, not clipping. No policy clamps positions, rejects touches or chooses whether out-of-bounds input should draw. Silently clamping would turn movement outside the target into repeated edge positions. If a consumer filters input, it must still handle terminal contacts to avoid leaving interactions active.

## Presentation uses resolved values

Place `TrackpadGuideView(mapping:)` in the destination coordinate space. It renders `mapping.mappedRect`, including its origin. Supply mapped active contacts to `TouchIndicatorsView(touches:)`. These views do not choose geometry or alter capture. The guide and indicators honour their respective Boolean environment settings.

```swift
ZStack {
  TrackpadGuideView(mapping: mapping)
  TouchIndicatorsView(touches: activeTouches.map { mapping.map($0) })
}
.trackpadGuideVisibility(true)
.trackpadTouchIndicators(true)
```

Maintain active contacts by ID across partial updates and remove ended/cancelled contacts. Keeping normalised samples lets indicators be reprojected when layout changes, rather than leaving stationary fingers at stale screen positions. With multiple source geometries, resolve each source's mapping and display corresponding guides; do not apply the first device's proportions to every contact.

## Coordinate conversion belongs to the consumer

For viewport-based input, map into the viewport and then apply the application's viewport-to-canvas transform:

```swift
let canvasTouch = mapping.map(touch)
  .transformed(by: viewportToCanvas)
```

The original sample remains available as `canvasTouch.source`. The consumer is responsible for knowing which destination space a `MappedTouchPoint` inhabits. Both position and velocity are converted; metadata and contact identity are preserved, and magnitude is always derived from velocity.

If mapping geometry changes during an interaction, decide whether to cancel, restart, freeze the mapping or continuously reproject. That is an interaction policy. Paperbark currently cancels active strokes when viewport size or scaling policy changes, then permits subsequent movement to start a new stroke. Manual regions and artwork-target controls are outside this migration.
