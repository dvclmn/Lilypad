# Normalised coordinates and device geometry

Understand which directions, distances and units a captured touch represents.

## Origin and axis directions

The origin is the point labelled `(0, 0)`. In Lilypad's capture output it is the bottom-left corner of the physical input surface. X increases towards the right; Y increases towards the top. Each axis independently spans `0...1`, irrespective of device size or view size. This follows [AppKit's normalised position contract](https://developer.apple.com/documentation/appkit/nstouch/normalizedposition).

| Physical location | Normalised position |
| --- | --- |
| Bottom-left | `(0, 0)` |
| Bottom-right | `(1, 0)` |
| Top-left | `(0, 1)` |
| Top-right | `(1, 1)` |
| Centre | `(0.5, 0.5)` |

The directions already existed in the previous capture implementation. The old modifier obscured them by switching to top-left view coordinates for fit/fill, while returning the same `TouchPoint` type. Now `TouchPoint` always means normalised input; `MappedTouchPoint` identifies converted input.

## Velocity uses the same axes

Velocity is change in position divided by elapsed seconds, then smoothed with an exponential moving average. Moving from `(0.25, 0.25)` to `(0.75, 0.5)` over half a second gives an unsmoothed velocity of `(1, 0.5)` normalised axis units per second. Positive Y means upward movement. The first valid sample has zero velocity; the default smoothing factor is 0.3, so reported velocity follows changes gradually. It is sample-based smoothing, not a time-constant filter.

Normalised velocity is not physical speed: a whole device width and a whole device height usually represent different physical distances. `magnitude` is computed from the velocity vector in its current units. It is not constrained to `0...1`.

When mapping into a top-left rectangle `R`, the equations are:

```text
x  = R.minX + normalisedX × R.width
y  = R.maxY − normalisedY × R.height
vx = normalisedVX × R.width
vy = −normalisedVY × R.height
speed = hypot(vx, vy)
```

For example, a velocity of `(0.5, 0.25)` mapped into a 320 × 200 rectangle becomes `(160, -50)` destination units per second. Moving the rectangle changes position but never adds velocity. The previous fit/fill implementation already performed this scaling correctly; the new API makes the relationship reusable and explicit.

A subsequent canvas transform must also transform velocity, using its linear part without translation. `MappedTouchPoint.transformed(by:)` performs both operations together. This reports finger velocity in the chosen space; it does not add apparent motion caused by changing the coordinate system itself.

## Source geometry

`TouchPoint.deviceSize` contains the source dimensions reported by [NSTouch.deviceSize](https://developer.apple.com/documentation/appkit/nstouch/devicesize), in device points (72 ppi). These are input-surface dimensions, not screen pixels or the capture view's size. Their ratio is useful for preserving the proportions of physical finger movement. They are not a device model identifier or a guarantee of precise physical calibration.

Geometry is attached to each contact, so different devices need not share proportions. Invalid or missing dimensions are represented by `nil`; a valid size already observed for a contact is retained when a later sample omits it. Lilypad supplies no universal 16:10 fallback. A consumer can wait for geometry, choose an explicit approximation, or use stretch, which needs no source proportions. Before the first event, there is no observed device geometry.

## Input validation and lifecycle

Non-finite or out-of-range positions are malformed input. A malformed first sample is dropped rather than turned into a fabricated corner touch. For an existing contact, Lilypad reports the last valid position and preserves its velocity baseline; an ended/cancelled sample still releases the contact. Repeated, backwards or non-finite timestamps do not move the velocity baseline. Valid captured positions therefore stay within the unit square without silently clamping motion to an edge.

Updates may be partial. An absent contact is not an ended contact. Resting is the driver's classification and differs from a stationary phase. Consumers decide whether resting contacts should affect their interaction.

## Trackpads, gestures and Magic Mouse

Lilypad accepts indirect `NSTouch` samples routed to its capture view. It does not derive absolute finger positions from mouse movement, scrolling or recognised gestures. Magic Mouse scrolling belongs to the scroll-event path; its existence does not establish support for an absolute, multi-contact trackpad surface. Do not promise Magic Mouse touch capture on the basis of indirect-touch filtering alone. Device/driver support still needs hardware verification. Apple's [event-handling guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/HandlingTouchEvents/HandlingTouchEvents.html) distinguishes touch samples from interpreted gesture and scroll events.
