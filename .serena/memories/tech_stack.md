## Tech stack

- Swift tools version 5.9 (`Package.swift`), Swift version 5.0 declared in podspec.
- Deployment target iOS 15+ (both `Package.swift` and `TagTextView.podspec` pin `.iOS(.v15)` / `'15.0'`).
- Library target (`TagTextView`) has zero external dependencies; only imports `SwiftUI`/`UIKit`/`Foundation`.
- Ships `Sources/PrivacyInfo.xcprivacy` as a resource via both SPM (`resources: [.process(...)]`) and
  CocoaPods (`s.resource_bundle`).
- Example app (`TagTextViewExample/`) uses CocoaPods, not SPM, and depends on `AlamofireImage` plus the
  local `TagTextView` pod.
