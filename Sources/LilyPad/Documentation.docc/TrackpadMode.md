# Capture enablement and guide visibility

Lilypad accepts independent Boolean values for capture and guide presentation. The consuming application owns any drawing-mode state, visibility policy and pointer behaviour.

```swift
@State private var capturesTouches = false

var body: some View {
  MyInputSurface()
    .trackpadTouches(isEnabled: capturesTouches) { touches, mappedRect in
      // Process input.
    }
    .trackpadGuideVisibility(capturesTouches)
    .toolbar {
      Toggle("Capture touches", isOn: $capturesTouches)
    }
}
```

Passing `capturesTouches` to both modifiers shows the guide only while capture is enabled. Pass `true` to show the guide even when capture is disabled, or `false` to hide it. Guide visibility does not affect touch callbacks. Both settings default to `true`.
