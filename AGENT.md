# AGENT.md

Guidance for any AI coding agent (Claude, Copilot, Cursor, etc.) working in this repository.
Editor/tool-specific files (e.g. `CLAUDE.md`) should point here rather than duplicating this
content.

## What this is

TagTextView is a Swift library: a `UITextView` subclass that detects `@mention` / `#hashtag`
tokens while the user types, plus a SwiftUI wrapper (`UIViewRepresentable`) around it. It's
published both via Swift Package Manager (`Package.swift`) and CocoaPods (`TagTextView.podspec`).

For the full internal architecture — the tagging engine's `NSRange` bookkeeping, the IME/marked-text
state machine, and the SwiftUI↔UIKit sync — read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
before touching `UITagTextView.swift` or `TextViewCoordinator.swift`. That logic is easy to break
in ways that only surface as caret jumps or mis-highlighted tags during real typing, not in a
quick read of the diff.

## Commands

- Build the library: `swift build` (from repo root).
- There is no test target and no CI config in this repo — don't invent `swift test` invocations.
- Run the example app: `cd TagTextViewExample && pod install`, then open
  `TagTextViewExample.xcworkspace` in Xcode (the CocoaPods workspace, not the bare `.xcodeproj`).
- No linter/formatter is configured (no SwiftLint/SwiftFormat config present).

## Definition of done

Since there's no automated test suite: a change is done when `swift build` succeeds, and — if it
touches editing/rendering/tagging behavior — when it's been manually exercised in the example app
(primary consumer: the chat message input, `SwiftUI/Views/MessageInput/`).

If a change touches anything under `Sources/`, bump `s.version` in `TagTextView.podspec` and the
`pod 'TagTextView', '~> x.y.z'` line in `README.md` together — CocoaPods resolves the pod against
the git tag matching `s.version`.

## Architecture at a glance

```
UITagTextView (UIKit, open class)      — all tagging logic
  └─ UIKitTagTextView                  — concrete subclass SwiftUI instantiates
       └─ TagTextView.Representable    — UIViewRepresentable
            └─ ...Coordinator          — bridges UIKit delegate → SwiftUI bindings
                 └─ TagTextView        — public SwiftUI View
                      └─ Modifiers.swift, ScrollingBehavior.swift — chainable config
```

Source root: `Sources/TagTextView/`. Directory names to know:
- `UITagTextView/` — UIKit core (`UITagTextView`, `TagModel`, `TagTextViewDelegate`).
- `SwiftUITextView/` — SwiftUI wrapper (`TagTextView`, `Representable`, `TextViewCoordinator`,
  `UIKitTagTextView`, `Modifiers`, `ScrollingBehavior`).
- `Extentions/` — `String` regex helpers (yes, "Extentions" — matches the existing spelling in
  this repo; don't rename it as a drive-by fix).

Full detail, including the tricky parts, lives in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Conventions worth knowing before editing

- Section headers use `// ******************************* MARK: - <Name>` throughout — match it
  in new code rather than a plain `// MARK:`.
- SwiftUI config is chainable value-returning modifiers (`Modifiers.swift`):
  `func x(_:) -> TagTextView { var view = self; view.x = ...; return view }`, not
  `@propertyWrapper`/environment-based config.
- `TagTextViewDelegate` has an extension with no-op defaults for every method — conformers only
  override what they need.
- Tag positions are `NSRange`s in `TagModel.range`, kept in sync by manual range-shifting math on
  every text mutation, not by diffing/re-deriving on each keystroke.
