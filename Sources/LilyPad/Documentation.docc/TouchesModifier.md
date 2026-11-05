# Capturing trackpad touches

Capture input in local view coordinates, with optional guides and touch indicators.

## A self-contained capture surface

Apply `.trackpadTouches(...)` to a view whose bounds define the input surface:

```swift
Color.clear
  .trackpadTouches(mode: .active(hidesPointer: false)) { touches, mappedRect in
    for touch in touches {
      print("Finger \(touch.touchOrder + 1): \(touch.position)")
    }
  }
  .trackpadGuideVisibility(.drawingMode)
  .trackpadTouchIndicators(true)
```

The modifier reads the surface's size inside an overlay. It does not size the underlying view, copy the geometry into state or publish geometry through the environment. The view must receive useful bounds from its own layout or its parent.

`.fit` maps the trackpad's aspect ratio within those bounds, while `.fill` fills them with cropping. Both produce positions in local points with a top-left origin, and velocities in points per second. `.normalised` leaves touch positions and velocities unchanged, using the trackpad's bottom-left origin. The returned `TrackpadMappedRect.rect` is always in local viewport points; for `.normalised`, it describes the viewport guide rather than a transform applied to the touches.

The callback delivers touch updates in first-contact order, including ended and cancelled touches. An update may contain only some active fingers. Capture defaults to `.inactive`; explicitly pass an active mode when input is wanted.

## Share geometry when it is already available

When a parent already measures the same surface, pass that size to skip Lilypad's geometry reader entirely:

```swift
GeometryReader { geometry in
  Color.clear
    .trackpadTouches(
      viewportSize: geometry.size,
      mode: .active(hidesPointer: false)
    ) { touches, mappedRect in
      // Use the same geometry.size for other tools on this surface.
    }
}
```

The supplied value must describe the capture surface's untransformed local bounds in points. An artwork's document size, its transformed frame and an ancestor's safe-area rectangle describe different things. Sharing a value is appropriate only when consumers agree on the surface, units, coordinate space and update timing. Merely using the same measurement helper does not make separate calls share their measurements.

Zero, negative and non-finite dimensions suspend capture and its overlays until a valid size arrives. The explicit-size overload does not silently substitute another measurement. Keep this geometry current during resize and inspector or sidebar changes. Avoid debouncing geometry used for input mapping: the surface and its coordinate conversion should agree while an interaction is in progress.

## Configure presentation through the environment

`.trackpadTouches(...)` installs the internal `TrackpadTouchesModifier`. That modifier reads `EnvironmentValues.trackpadGuideVisibility` and `EnvironmentValues.showsTrackpadTouchIndicators` to decide which visual overlays to display. The AppKit touch handler does not read these settings.

The two focused presentation modifiers write those values into the environment:

```swift
Color.clear
  .trackpadTouches(mode: .active(hidesPointer: false)) { touches, mappedRect in
    // Handle input regardless of whether indicators are visible.
  }
  .trackpadGuideVisibility(.never)
  .trackpadTouchIndicators(false)
```

Place presentation modifiers after `.trackpadTouches(...)` in a chain, or apply them to an ancestor containing capture surfaces. A modifier later in the chain wraps the earlier view and provides its environment. Setting the environment only on the underlying content, before adding the capture modifier, does not configure that outer capture modifier. A setting closer to a capture surface overrides an ancestor's setting.

The defaults are an always-visible guide and enabled touch indicators. Indicators appear only while capture is active, and are hidden for `.normalised` mapping because its positions are not local points. These options change presentation, not callback delivery or touch ordering.

## Integrate with CanvasKit without a package dependency

Lilypad maps trackpad input into a view; it does not interpret document size, pan, zoom or rotation. An application can apply its CanvasKit mapper to convert those local viewport positions into artwork coordinates. Transform velocity using the linear part of the same transform, without translation, and recompute its magnitude from that velocity.

For Paperbark's existing `CanvasView` viewport overlay, the measured-size version can replace the former argument list while retaining the existing callback:

```swift
GeometryReader { geometry in
  Color.clear
    .trackpadTouches(
      viewportSize: geometry.size,
      mode: store.drawingMode
    ) { touches, mappedRect in
      updateIfChanged(&store.trackpadMappedRect, to: mappedRect)
      handleTouches(touches)
    }
    .trackpadGuideVisibility(store.preferences.trackpadPreferences.guideVisibility)
    .trackpadTouchIndicators(store.preferences.showingTouchIndicators)
}
```

Alternatively, remove the outer `GeometryReader` and omit `viewportSize:` to let Lilypad measure the `Color.clear` surface itself. Keep this surface in CanvasKit's viewport overlay, so its local coordinates agree with the viewport-to-artwork mapper. Measuring the transformed artwork would establish a different coordinate contract.

## Migrate existing clients

The original overload remains available with a deprecation warning, so clients can migrate independently. Its `canvasSize`, `zoomLevel` and `zoomRange` arguments remain unused. Its `viewportRect` contributes only its size; a `nil` rectangle continues to suspend capture. Its explicit guide and indicator arguments override inherited presentation settings.

`viewportRectWaitDuration` is now ignored. Previously it delayed installing capture even when geometry was already available. Both old and new overloads now start capture as soon as valid geometry is supplied, without showing a message about a missing environment value.

## Review the integration

Check input immediately after opening a view, after resizing it and after changing inspector or sidebar visibility. Compare local measurement with an explicit size for the same surface. Confirm guide settings inherit from an ancestor and can be overridden locally, indicators do not affect callbacks, inactive mode stops capture, and `.normalised` retains its original coordinate convention. Check pointer restoration when changing mode, leaving the view and switching applications.
