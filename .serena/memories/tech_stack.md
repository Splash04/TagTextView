## Tech stack

- Swift 6 language mode (strict concurrency): tools version 6.0 (`Package.swift`), `swift_version '6.0'` in the podspec, and `SWIFT_VERSION = 6.0` in the example app project.
- Deployment target iOS 15+ (both `Package.swift` and `TagTextView.podspec` pin `.iOS(.v15)` / `'15.0'`).
- Library target (`TagTextView`) has zero external dependencies; only imports `SwiftUI`/`UIKit`/`Foundation`.
- Ships `Sources/PrivacyInfo.xcprivacy` as a resource via both SPM (`resources: [.process(...)]`) and
  CocoaPods (`s.resource_bundle`).
- Example app (`TagTextViewExample/`) uses CocoaPods, not SPM, and depends on `AlamofireImage` plus the
  local `TagTextView` pod.
