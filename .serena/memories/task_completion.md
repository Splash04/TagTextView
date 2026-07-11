## Definition of done

No automated test suite or CI exists in this repo. For a change to be considered done:
- `swift build` succeeds from repo root.
- If the change touches rendering/editing/tagging behavior, manually verify via the example app:
  `cd TagTextViewExample && pod install` then open `TagTextViewExample.xcworkspace` and exercise the
  affected flow (chat message input is the primary consumer, see `MessageInputView`/`MessageInputViewModel`).
- When changing anything under `Sources/`, keep versioning in sync: bump `s.version` in
  `TagTextView.podspec` (CocoaPods resolves the pod off the git tag matching this version) and update the
  `pod 'TagTextView', '~> x.y.z'` line in `README.md` to match.
