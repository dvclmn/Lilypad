# Capture enablement and presentation

The consumer owns interaction mode, pointer behaviour and active-contact state.

`trackpadTouches(isEnabled:perform:)` controls capture only. Display a `TrackpadGuideView` and `TouchIndicatorsView` separately when needed. The existing `trackpadGuideVisibility(_:)` and `trackpadTouchIndicators(_:)` Boolean environment modifiers configure these explicit presentation views; they do not cause capture to create overlays.

A guide can remain visible while capture is disabled. Clear active input when disabling or removing capture, and hide or empty its indicators. The consumer decides whether disabling should complete or cancel an interaction.
