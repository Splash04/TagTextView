# Architecture

TagTextView is a `UITextView` subclass that detects `@mention` and `#hashtag` tokens as the
user types, plus a thin SwiftUI wrapper around it. There is one implementation of the tagging
logic (UIKit); SwiftUI gets it for free via `UIViewRepresentable`.

## Layers

```
UITagTextView (UIKit, open class)      — all tagging logic lives here
  └─ UIKitTagTextView                  — concrete subclass SwiftUI instantiates (adds Esc-to-resign)
       └─ TagTextView.Representable    — UIViewRepresentable wrapping UIKitTagTextView
            └─ TagTextView.Representable.Coordinator  — bridges UIKit delegate → SwiftUI bindings
                 └─ TagTextView (SwiftUI View)         — public entry point
                      └─ Modifiers.swift, ScrollingBehavior.swift — chainable config
```

- `Sources/TagTextView/UITagTextView/UITagTextView.swift` — the tagging engine (see below).
- `Sources/TagTextView/UITagTextView/TagModel.swift` — `Identifiable` value type: `id`, `name`,
  `range` (`NSRange` into the text), `data`, `isHashTag`, optional `customTextAttributes`.
- `Sources/TagTextView/UITagTextView/TagTextViewDelegate.swift` — UIKit-style delegate protocol,
  mirrors `UITextViewDelegate` plus tag-specific callbacks. All methods have no-op defaults.
- `Sources/TagTextView/SwiftUITextView/UIKitTagTextView.swift` — trivial subclass, only adds an
  Esc key command that resigns first responder.
- `Sources/TagTextView/SwiftUITextView/Representable.swift` — the `UIViewRepresentable`. Holds
  every configuration value as a plain property (font, colors, symbols, scrolling behavior, …)
  and forwards them to the coordinator on every SwiftUI diff.
- `Sources/TagTextView/SwiftUITextView/TextViewCoordinator.swift` — the `NSObject` coordinator:
  owns the `UIKitTagTextView` instance, implements `TagTextViewDelegate`, and pushes UIKit events
  back into the SwiftUI bindings (`text`, `tags`, `calculatedHeight`, `isFirstResponder`). Also
  hosts a `NotificationCenter`-based side channel (see below).
- `Sources/TagTextView/SwiftUITextView/TagTextView.swift` — the public SwiftUI `View`. Two
  initializers: one takes a `Binding<String>`, one a `Binding<NSAttributedString>` (sets
  `allowRichText`). Renders `Representable` sized by `ScrollingBehavior`, with an optional
  placeholder overlay.
- `Sources/TagTextView/SwiftUITextView/Modifiers.swift` — SwiftUI-style value-returning modifiers
  (`.mentionColor(_:)`, `.hashTagFont(_:)`, `.textLengthLimit(_:)`, …), following the same pattern
  as the upstream `SwiftUI-Plus/TextView` this was based on.
- `Sources/TagTextView/SwiftUITextView/ScrollingBehavior.swift` — `.enable` / `.disable` /
  `.maxHeight(_:)`, drives min/max frame height, text container insets and whether
  `isScrollEnabled` is on.
- `Sources/TagTextView/Extentions/String.swift` — regex-based `findHashtags()` /
  `findMentions()`, plus blank-string helpers. (Directory name keeps the original "Extentions"
  spelling — don't rename it as a drive-by fix.)

## Tagging engine (`UITagTextView`)

The engine tracks tags as an array of `TagModel` (`arrTags`), each holding an `NSRange` into the
current text. There is no re-derivation on every keystroke — ranges are shifted manually as the
text changes (`updateArrTags`, insertion/deletion handling in
`textView(_:shouldChangeTextIn:replacementText:)`). This is the main source of complexity:

- **Attribute application** (`updateAttributeText`) mutates `textStorage` in place
  (`beginEditing`/`setAttributes`/`addAttributes`/`endEditing`) rather than reassigning
  `.attributedText`, specifically so the caret/selection position is never disturbed as a side
  effect. Passing a negative `selectedLocation` means "leave the caret where it is" — used by
  passive refresh callers.
- **IME / predictive text ("marked text")** is the trickiest part. While
  `markedTextRange != nil`, the view must not rewrite attributes or tag ranges — the system owns
  composition and caret placement at that point. `textViewDidChange` and `shouldChangeTextIn`
  detect this and just set a `needsPostCompositionRefresh` flag instead of acting. Once
  composition ends, `fixedWhenMarkedTextUnmatch()` runs once to re-derive `arrTags` ranges from a
  fresh `findMentions()` regex scan, because composition can silently desync the manually-tracked
  ranges. `recalculateAttributes()` (called from the SwiftUI coordinator's `update`) is a no-op
  while marked text is active for the same reason.
- **Deleting inside a tag** removes that `TagModel` from `arrTags` and collapses the tag to a
  single space (via `textStorage.replaceCharacters`, not `.text = `) instead of deleting the tag
  text outright.
- **`textLengthLimit`** interacts with tag insertion: `addTag` truncates the inserted tag text
  itself to fit the remaining character budget rather than rejecting the insert.
- Regexes (`tagRegex` in `UITagTextView`, `_hashtagRegex`/`_mentionRegex` in `String.swift`) are
  cached and only rebuilt when the underlying symbol/pattern actually changes.

## SwiftUI ↔ UIKit sync (`Coordinator`)

`Coordinator.update(representable:)` runs on every SwiftUI diff and pushes representable state
into the live `UIKitTagTextView`. Text is only pushed down when it differs from the view's current
string, to avoid fighting the user's typing; going to empty text goes through `clearText()`
instead of `.text = ""` so UIKit's text-input system is notified correctly even while the view is
first responder. `recalculateHeight()` measures via `sizeThatFits` and defers the write to
`calculatedHeight` to the next run loop tick to avoid "modifying state during view update".

## Cross-instance mutation via `NotificationCenter`

`TextViewCoordinator.swift` also defines static helpers on `TagTextView`
(`TagTextView.addTag(...)`, `.setTags(...)`, etc.) that post an `NSNotification`
(`Notification.Name.addTagNotification`) instead of going through a `Binding`. Each `Coordinator`
observes this notification and filters by an integer `viewId` (`-1` means "broadcast to all
instances"). This exists to let code outside the SwiftUI view hierarchy mutate a specific
`TagTextView`'s tags/text, and is flagged in-code as a known workaround rather than a deliberate
final design ("Needs to find better solution to adding tags from SwiftUI").

## Distribution

The library is published both as a Swift package (`Package.swift`) and a CocoaPods pod
(`TagTextView.podspec`). Both point at the same `Sources/TagTextView` tree and must be kept in
sync: bump `s.version` in the podspec (CocoaPods resolves against the matching git tag) and update
the `pod 'TagTextView', '~> x.y.z'` line in `README.md` together.

The example app (`TagTextViewExample/`) consumes the library as a CocoaPods pod pointed at the
repo root (`pod 'TagTextView', :path => '../'`) — it does not vendor a copy of the source.
