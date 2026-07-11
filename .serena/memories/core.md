## TagTextView — core map

Single Swift package: a `UITextView` subclass with `@mention`/`#hashtag` tagging,
wrapped for SwiftUI via `UIViewRepresentable`. Source root: `Sources/TagTextView`.

Layers (bottom-up):
- `UITagTextView/UITagTextView.swift` — open UIKit class, all tagging logic (regex matching,
  `arrTags` range bookkeeping, IME/marked-text handling).
- `UITagTextView/TagModel.swift`, `TagTextViewDelegate.swift` — data model + delegate protocol.
- `SwiftUITextView/UIKitTagTextView.swift` — concrete subclass SwiftUI instantiates (adds Esc-to-resign).
- `SwiftUITextView/Representable.swift` (+ `TextViewCoordinator.swift`) — `UIViewRepresentable` +
  `Coordinator` bridging UIKit delegate callbacks to SwiftUI bindings.
- `SwiftUITextView/TagTextView.swift` — public SwiftUI `View` entry point (2 inits: plain `String` or `NSAttributedString`).
- `SwiftUITextView/Modifiers.swift`, `ScrollingBehavior.swift` — SwiftUI-style chainable config modifiers.
- `Extentions/String.swift` — hashtag/mention regex helpers, blank-string helpers (note: dir is
  spelled "Extentions", not "Extensions" — matches existing code, don't "fix" the typo mid-edit).

Dual distribution: **Package.swift** (SPM) and **TagTextView.podspec** (CocoaPods) both describe the
same `Sources/TagTextView` tree and must be kept in sync on version bumps — see `mem:task_completion`.

Example app: `TagTextViewExample/` consumes the library as a CocoaPods pod pointed at the repo root
(`pod 'TagTextView', :path => '../'`) — it does NOT vendor a local copy of the source. A previously
vendored copy under `TagTextViewExample/TagTextViewExample/TagTextView/` was removed; do not recreate it.

No test target and no CI config exist in this repo. Further reading: `mem:tech_stack`,
`mem:suggested_commands`, `mem:conventions`, `mem:task_completion`.
