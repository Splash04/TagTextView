## Conventions

- Section headers use a distinct banner-comment style throughout the codebase:
  `// ******************************* MARK: - <Name>` — used instead of a plain `// MARK:`. Match it in new code.
- SwiftUI configuration follows the SwiftUI-Plus/TextView chainable-modifier pattern (see
  `SwiftUITextView/Modifiers.swift`): each modifier is `func x(_:) -> TagTextView { var view = self; view.x = ...; return view }`,
  not `@propertyWrapper`/environment based config.
- `UITagTextView` is `open` and meant to be subclassed; `UIKitTagTextView` is the concrete subclass the
  SwiftUI `Representable` actually instantiates (adds Esc-key → `resignFirstResponder`).
- `TagTextViewDelegate` (in `TagTextViewDelegate.swift`) has an extension with no-op default
  implementations for every method — conformers only override what they need.
- Tag positions are tracked as `NSRange` in `TagModel.range`. `UITagTextView.arrTags` is kept in sync
  manually on every text mutation via range-shifting math (`updateArrTags`, `addTag`, etc.) — there is no
  diffing/re-derivation step, so range bookkeeping bugs show up as tags highlighting the wrong text.
  Deeper detail: `mem:tagging_engine`.
- IME/predictive text ("marked text") is special-cased across `textViewDidChange`,
  `textViewDidChangeSelection`, and `shouldChangeTextIn` to avoid caret jumps and tag-range desync during
  composition — see `mem:tagging_engine` / `docs/ARCHITECTURE.md` before touching that code.
- Cross-instance tag mutation from outside the SwiftUI view binding goes through `NotificationCenter`
  (`TextViewCoordinator.swift`, `Notification.Name.addTagNotification`), keyed by an integer `viewId`, not
  through the `Binding` — flagged in-code as a known workaround, not a deliberate final design
  ("Needs to find better solution to adding tags from SwiftUI").
